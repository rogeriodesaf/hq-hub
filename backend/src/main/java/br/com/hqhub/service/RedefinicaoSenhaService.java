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

import java.time.LocalDateTime;
import java.util.UUID;

@ApplicationScoped
public class RedefinicaoSenhaService {

    private final UsuarioRepository usuarioRepository;
    private final TokenRedefinicaoSenhaRepository tokenRepository;
    private final Mailer mailer;
    private final String urlBase;

    public RedefinicaoSenhaService(
            UsuarioRepository usuarioRepository,
            TokenRedefinicaoSenhaRepository tokenRepository,
            Mailer mailer,
            @ConfigProperty(name = "hqhub.url-base") String urlBase) {
        this.usuarioRepository = usuarioRepository;
        this.tokenRepository = tokenRepository;
        this.mailer = mailer;
        this.urlBase = urlBase;
    }

    @Transactional
    public void solicitar(SolicitacaoRedefinicaoSenhaDTO dto) {
        usuarioRepository.buscarPorEmail(dto.email()).ifPresent(usuario -> {
            tokenRepository.excluirPorUsuario(usuario);

            String token = UUID.randomUUID().toString();
            TokenRedefinicaoSenha entidade = new TokenRedefinicaoSenha();
            entidade.setToken(token);
            entidade.setUsuario(usuario);
            entidade.setExpiraEm(LocalDateTime.now().plusHours(1));
            tokenRepository.persist(entidade);

            String link = urlBase + "/entrar?token=" + token;
            String html = "<p>Olá, <strong>" + usuario.getNome() + "</strong>!</p>"
                    + "<p>Clique no link abaixo para redefinir sua senha no HQ-HUB. "
                    + "O link é válido por <strong>1 hora</strong>.</p>"
                    + "<p><a href=\"" + link + "\">" + link + "</a></p>"
                    + "<p>Se você não solicitou a redefinição, ignore este e-mail.</p>";

            mailer.send(Mail.withHtml(dto.email(), "Redefinição de senha — HQ-HUB", html));
        });
        // Não revelar se o e-mail existe ou não (prevenção de enumeração)
    }

    @Transactional
    public void redefinir(RedefinicaoSenhaDTO dto) {
        TokenRedefinicaoSenha entidade = tokenRepository.buscarPorToken(dto.token())
                .orElseThrow(() -> new RegraNegocioException("Token inválido ou expirado."));

        if (entidade.getExpiraEm().isBefore(LocalDateTime.now())) {
            tokenRepository.delete(entidade);
            throw new RegraNegocioException("Token inválido ou expirado.");
        }

        Usuario usuario = entidade.getUsuario();
        usuario.setSenha(BcryptUtil.bcryptHash(dto.novaSenha()));
        tokenRepository.delete(entidade);
    }
}
