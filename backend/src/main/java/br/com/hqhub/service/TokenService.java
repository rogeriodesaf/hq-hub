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

    private final String segredoJwt;
    private final Duration duracaoToken;

    public TokenService(
            @ConfigProperty(name = "hqhub.jwt.segredo") String segredoJwt,
            @ConfigProperty(name = "hqhub.jwt.duracao-horas", defaultValue = "24") long duracaoHoras) {
        this.segredoJwt = segredoJwt;
        this.duracaoToken = Duration.ofHours(Math.max(1, duracaoHoras));
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
                .expiresAt(agora.plus(duracaoToken))
                .signWithSecret(segredoJwt);
    }

    public long obterTempoExpiracaoEmSegundos() {
        return duracaoToken.toSeconds();
    }
}
