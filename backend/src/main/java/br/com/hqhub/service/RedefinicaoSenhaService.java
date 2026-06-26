package br.com.hqhub.service;

import br.com.hqhub.dto.RedefinicaoSenhaDTO;
import br.com.hqhub.dto.SolicitacaoRedefinicaoSenhaDTO;
import br.com.hqhub.entity.TokenRedefinicaoSenha;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.repository.TokenRedefinicaoSenhaRepository;
import br.com.hqhub.repository.UsuarioRepository;
import io.quarkus.elytron.security.common.BcryptUtil;
import io.quarkus.mailer.Mail;
import io.quarkus.mailer.Mailer;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.jboss.logging.Logger;

import java.time.LocalDateTime;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicReference;

@ApplicationScoped
public class RedefinicaoSenhaService {

    private static final Logger LOG = Logger.getLogger(RedefinicaoSenhaService.class);

    private final UsuarioRepository usuarioRepository;
    private final TokenRedefinicaoSenhaRepository tokenRepository;
    private final Mailer mailer;
    private final String urlBase;
    private final String smtpUsuario;
    private final String smtpSenha;

    public RedefinicaoSenhaService(
            UsuarioRepository usuarioRepository,
            TokenRedefinicaoSenhaRepository tokenRepository,
            Mailer mailer,
            @ConfigProperty(name = "hqhub.url-base") String urlBase,
            @ConfigProperty(name = "hqhub.smtp.usuario") String smtpUsuario,
            @ConfigProperty(name = "hqhub.smtp.senha") String smtpSenha) {
        this.usuarioRepository = usuarioRepository;
        this.tokenRepository = tokenRepository;
        this.mailer = mailer;
        this.urlBase = urlBase;
        this.smtpUsuario = smtpUsuario;
        this.smtpSenha = smtpSenha;
    }

    @Transactional
    public String solicitar(SolicitacaoRedefinicaoSenhaDTO dto) {
        String erroConfiguracao = validarConfiguracaoEmail();
        if (erroConfiguracao != null) {
            return erroConfiguracao;
        }

        AtomicReference<String> erroEnvio = new AtomicReference<>();
        usuarioRepository.buscarPorEmail(dto.email()).ifPresent(usuario -> {
            tokenRepository.excluirPorUsuario(usuario);

            String token = UUID.randomUUID().toString();
            TokenRedefinicaoSenha entidade = new TokenRedefinicaoSenha();
            entidade.setToken(token);
            entidade.setUsuario(usuario);
            entidade.setExpiraEm(LocalDateTime.now().plusHours(1));
            tokenRepository.persist(entidade);

            String link = urlBase + "/entrar?token=" + token;
            String html = "<p>Ola, <strong>" + usuario.getNome() + "</strong>!</p>"
                    + "<p>Clique no link abaixo para redefinir sua senha no HQ-HUB. "
                    + "O link e valido por <strong>1 hora</strong>.</p>"
                    + "<p><a href=\"" + link + "\">" + link + "</a></p>"
                    + "<p>Se voce nao solicitou a redefinicao, ignore este e-mail.</p>";

            try {
                mailer.send(Mail.withHtml(dto.email(), "Redefinicao de senha - HQ-HUB", html));
            } catch (RuntimeException excecao) {
                LOG.errorf(excecao, "Falha ao enviar e-mail de redefinicao de senha para %s.", dto.email());
                erroEnvio.set("Nao foi possivel enviar o e-mail de redefinicao agora.");
            }
        });
        // Nao revelar se o e-mail existe ou nao (prevencao de enumeracao).
        return erroEnvio.get();
    }

    @Transactional
    public void redefinir(RedefinicaoSenhaDTO dto) {
        TokenRedefinicaoSenha entidade = tokenRepository.buscarPorToken(dto.token())
                .orElseThrow(() -> new RegraNegocioException("Token invalido ou expirado."));

        if (entidade.getExpiraEm().isBefore(LocalDateTime.now())) {
            tokenRepository.delete(entidade);
            throw new RegraNegocioException("Token invalido ou expirado.");
        }

        Usuario usuario = entidade.getUsuario();
        usuario.setSenha(BcryptUtil.bcryptHash(dto.novaSenha()));
        tokenRepository.delete(entidade);
    }

    private String validarConfiguracaoEmail() {
        if (smtpUsuario == null || smtpUsuario.isBlank() || "__NAO_CONFIGURADO__".equals(smtpUsuario)
                || smtpSenha == null || smtpSenha.isBlank() || "__NAO_CONFIGURADO__".equals(smtpSenha)) {
            LOG.error("SMTP de redefinicao de senha nao configurado. Informe HQHUB_SMTP_USER e HQHUB_SMTP_PASS.");
            return "Envio de e-mail nao configurado no servidor.";
        }
        return null;
    }
}
