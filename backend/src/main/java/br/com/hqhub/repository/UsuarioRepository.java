package br.com.hqhub.repository;

import java.util.List;
import java.util.Optional;

import br.com.hqhub.entity.Usuario;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class UsuarioRepository implements PanacheRepository<Usuario> {

    public Optional<Usuario> buscarPorEmail(String email) {
        if (email == null || email.isBlank()) {
            return Optional.empty();
        }
        return find("lower(email) = ?1", email.trim().toLowerCase()).firstResultOptional();
    }

    public boolean existePorEmail(String email) {
        return buscarPorEmail(email).isPresent();
    }

    public List<Usuario> buscar(String busca) {
        if (busca == null || busca.isBlank()) {
            return find("order by nome").list();
        }

        String termo = "%" + busca.trim().toLowerCase() + "%";
        return find("lower(nome) like ?1 or lower(email) like ?1 order by nome", termo)
                .page(0, 20)
                .list();
    }
}
