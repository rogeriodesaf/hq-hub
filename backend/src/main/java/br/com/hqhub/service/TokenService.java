package br.com.hqhub.service;

import java.time.Duration;
import java.time.Instant;
import java.util.Set;

import org.eclipse.microprofile.config.inject.ConfigProperty;

import br.com.hqhub.entity.Usuario;
import io.smallrye.jwt.build.Jwt;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class TokenService {

    private static final Duration DURACAO_TOKEN = Duration.ofHours(2);

    private final String segredoJwt;

    public TokenService(@ConfigProperty(name = "hqhub.jwt.segredo") String segredoJwt) {
        this.segredoJwt = segredoJwt;
    }

    public String gerarToken(Usuario usuario) {
        Instant agora = Instant.now();

        return Jwt.issuer("hqhub")
                .subject(usuario.getId().toString())
                .upn(usuario.getEmail())
                .groups(Set.of(usuario.getPerfil().name()))
                .claim("perfil", usuario.getPerfil().name())
                .claim("nome", usuario.getNome())
                .issuedAt(agora)
                .expiresAt(agora.plus(DURACAO_TOKEN))
                .signWithSecret(segredoJwt);
    }

    public long obterTempoExpiracaoEmSegundos() {
        return DURACAO_TOKEN.toSeconds();
    }
}
