package br.com.hqhub.repository;

import java.util.Optional;

import br.com.hqhub.entity.ConfiguracaoColecao;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ConfiguracaoColecaoRepository implements PanacheRepository<ConfiguracaoColecao> {

    public Optional<ConfiguracaoColecao> buscarPorUsuario(Long usuarioId) {
        return find("usuario.id", usuarioId).firstResultOptional();
    }
}
