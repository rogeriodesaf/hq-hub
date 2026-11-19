package br.com.hqhub.service;

import br.com.hqhub.dto.RedefinicaoSenhaDTO;
import br.com.hqhub.dto.SolicitacaoRedefinicaoSenhaDTO;
import br.com.hqhub.entity.TokenRedefinicaoSenha;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.repository.SessaoPersistenteRepository;
import br.com.hqhub.repository.TokenRedefinicaoSenhaRepository;
import br.com.hqhub.repository.UsuarioRepository;
import io.quarkus.elytron.security.common.BcryptUtil;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.HexFormat;
import java.util.Locale;
import java.util.concurrent.ConcurrentHashMap;

@ApplicationScoped
public class RedefinicaoSenhaService {
    private static final int LIMITE_PEDIDOS = 3;
    private static final long JANELA_MS = 15 * 60 * 1000L;
    private final UsuarioRepository usuarioRepository;
    private final TokenRedefinicaoSenhaRepository tokenRepository;
    private final SessaoPersistenteRepository sessaoRepository;
    private final EmailRedefinicaoSenhaService emailService;
    private final String urlBase;
    private final SecureRandom random = new SecureRandom();
    // O limite vale também para endereços inexistentes; só o hash fica em memória.
    private final ConcurrentHashMap<String, Janela> pedidos = new ConcurrentHashMap<>();

    public RedefinicaoSenhaService(UsuarioRepository usuarioRepository,
            TokenRedefinicaoSenhaRepository tokenRepository,
            SessaoPersistenteRepository sessaoRepository,
            EmailRedefinicaoSenhaService emailService,
            @ConfigProperty(name = "hqhub.url-base") String urlBase) {
        this.usuarioRepository = usuarioRepository;
        this.tokenRepository = tokenRepository;
        this.sessaoRepository = sessaoRepository;
        this.emailService = emailService;
        this.urlBase = urlBase;
    }

    @Transactional
    public void solicitar(SolicitacaoRedefinicaoSenhaDTO dto) {
        String endereco = dto.email().trim().toLowerCase(Locale.ROOT);
        if (!permitir(hash(endereco))) {
            return;
        }
        if (!emailService.configurado()) {
            throw new EmailRedefinicaoSenhaService.Falha("SEM_CONFIGURACAO");
        }
        usuarioRepository.buscarPorEmail(endereco).ifPresent(usuario -> {
            LocalDateTime agora = LocalDateTime.now();
            // Cooldown no banco também funciona após reinício e em múltiplas réplicas.
            if (tokenRepository.existeRecentePorUsuario(usuario, agora.plusMinutes(55))) {
                return;
            }
            byte[] bytes = new byte[32];
            random.nextBytes(bytes);
            String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
            TokenRedefinicaoSenha entidade = new TokenRedefinicaoSenha();
            entidade.setToken(hash(token));
            entidade.setUsuario(usuario);
            entidade.setExpiraEm(agora.plusHours(1));
            tokenRepository.excluirPorUsuario(usuario);
            tokenRepository.persist(entidade);
            String link = urlBase.replaceAll("/+$", "") + "/entrar#token=" + token;
            String html = "<p>Você solicitou a redefinição da senha do Coleciona HQ.</p>"
                    + "<p>O link abaixo é válido por 1 hora e só pode ser usado uma vez.</p>"
                    + "<p><a href=\"" + link + "\">Redefinir minha senha</a></p>"
                    + "<p>Se não fez essa solicitação, ignore esta mensagem.</p>";
            // Falha de envio deve reverter a transação e preservar token anterior.
            emailService.enviar(endereco, html);
        });
    }

    @Transactional
    public void redefinir(RedefinicaoSenhaDTO dto) {
        String recebido = dto.token();
        // Links UUID enviados pela versão anterior continuam válidos até expirar.
        String chave = recebido.matches("[0-9a-fA-F-]{36}") ? recebido : hash(recebido);
        TokenRedefinicaoSenha entidade = tokenRepository.buscarPorTokenParaConsumo(chave)
                .orElseThrow(() -> new RegraNegocioException("Token inválido ou expirado."));
        if (!entidade.getExpiraEm().isAfter(LocalDateTime.now())) {
            throw new RegraNegocioException("Token inválido ou expirado.");
        }
        Usuario usuario = entidade.getUsuario();
        usuario.setSenha(BcryptUtil.bcryptHash(dto.novaSenha()));
        sessaoRepository.revogarPorUsuario(usuario);
        tokenRepository.delete(entidade);
    }

    private boolean permitir(String chave) {
        long agora = System.currentTimeMillis();
        if (pedidos.size() > 10_000) {
            pedidos.entrySet().removeIf(e -> agora - e.getValue().inicio >= JANELA_MS);
            if (pedidos.size() > 10_000) return false;
        }
        Janela janela = pedidos.compute(chave, (ignorada, atual) -> {
            if (atual == null || agora - atual.inicio >= JANELA_MS) return new Janela(agora, 1);
            return new Janela(atual.inicio, atual.total + 1);
        });
        return janela.total <= LIMITE_PEDIDOS;
    }

    private String hash(String valor) {
        try {
            return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256")
                    .digest(valor.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException excecao) {
            throw new IllegalStateException("SHA-256 indisponível");
        }
    }

    private record Janela(long inicio, int total) { }
}
