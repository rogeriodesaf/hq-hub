package br.com.hqhub.repository;

import java.util.Optional;

import br.com.hqhub.entity.Usuario;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class UsuarioRepository implements PanacheRepository<Usuario> {

    public Optional<Usuario> buscarPorEmail(String email) {
        return find("email", email).firstResultOptional();
    }

    public boolean existePorEmail(String email) {
        return buscarPorEmail(email).isPresent();
    }
}
