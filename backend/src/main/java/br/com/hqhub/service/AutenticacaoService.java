package br.com.hqhub.service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.HexFormat;

import br.com.hqhub.dto.AutenticacaoUsuarioDTO;
import br.com.hqhub.dto.UsuarioAutenticadoDTO;
import br.com.hqhub.entity.SessaoPersistente;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.repository.SessaoPersistenteRepository;
import br.com.hqhub.repository.UsuarioRepository;
import io.quarkus.elytron.security.common.BcryptUtil;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class AutenticacaoService {

    private final UsuarioRepository usuarioRepository;
    private final TokenService tokenService;
    private final UrlPublicaService urlPublicaService;
    private final SessaoPersistenteRepository sessaoRepository;
    private final SecureRandom random = new SecureRandom();

    public AutenticacaoService(UsuarioRepository usuarioRepository, TokenService tokenService,
            UrlPublicaService urlPublicaService, SessaoPersistenteRepository sessaoRepository) {
        this.usuarioRepository = usuarioRepository;
        this.tokenService = tokenService;
        this.urlPublicaService = urlPublicaService;
        this.sessaoRepository = sessaoRepository;
    }

    @Transactional
    public UsuarioAutenticadoDTO autenticar(AutenticacaoUsuarioDTO dto) {
        Usuario usuario = usuarioRepository.buscarPorEmail(dto.email())
                .orElseThrow(() -> new RegraNegocioException("E-mail ou senha invalidos."));

        if (!senhaConfere(dto.senha(), usuario.getSenha())) {
            throw new RegraNegocioException("E-mail ou senha invalidos.");
        }

        sessaoRepository.removerExpiradas();
        return resposta(usuario);
    }

    @Transactional
    public UsuarioAutenticadoDTO renovar(String refreshToken) {
        if (refreshToken == null || refreshToken.isBlank()) {
            throw new RegraNegocioException("Sessão inválida. Faça login novamente.");
        }
        SessaoPersistente sessao = sessaoRepository.findById(hash(refreshToken));
        if (sessao == null || !sessao.getExpiraEm().isAfter(LocalDateTime.now())) {
            throw new RegraNegocioException("Sessão expirada. Faça login novamente.");
        }
        Usuario usuario = sessao.getUsuario();
        sessaoRepository.delete(sessao);
        sessaoRepository.flush();
        return resposta(usuario);
    }

    @Transactional
    public void sair(String refreshToken) {
        if (refreshToken != null && !refreshToken.isBlank()) {
            sessaoRepository.deleteById(hash(refreshToken));
        }
    }

    private UsuarioAutenticadoDTO resposta(Usuario usuario) {
        String refreshToken = criarSessao(usuario);
        return new UsuarioAutenticadoDTO(
                usuario.getId(),
                usuario.getNome(),
                usuario.getEmail(),
                usuario.getPerfil().name(),
                usuario.getBio(),
                urlPublicaService.normalizarApiUrl(usuario.getFotoPerfilUrl()),
                urlPublicaService.normalizarApiUrl(usuario.getFotoPerfilThumbnailUrl()),
                urlPublicaService.normalizarApiUrl(usuario.getCapaPerfilUrl()),
                tokenService.gerarToken(usuario),
                refreshToken,
                "Bearer",
                tokenService.obterTempoExpiracaoEmSegundos(),
                "Login realizado com sucesso.");
    }

    private String criarSessao(Usuario usuario) {
        byte[] bytes = new byte[32];
        random.nextBytes(bytes);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        SessaoPersistente sessao = new SessaoPersistente();
        sessao.setTokenHash(hash(token));
        sessao.setUsuario(usuario);
        sessao.setExpiraEm(LocalDateTime.now().plusDays(180));
        sessaoRepository.persist(sessao);
        return token;
    }

    private String hash(String token) {
        try {
            return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256")
                    .digest(token.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException excecao) {
            throw new IllegalStateException("SHA-256 indisponível", excecao);
        }
    }

    private boolean senhaConfere(String senhaInformada, String senhaSalva) {
        if (senhaSalva == null || senhaInformada == null) {
            return false;
        }

        if (senhaSalva.startsWith("$2")) {
            return BcryptUtil.matches(senhaInformada, senhaSalva);
        }

        return senhaSalva.equals(senhaInformada);
    }
}
