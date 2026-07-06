package br.com.hqhub.repository;

import java.util.Optional;

import br.com.hqhub.entity.ColecaoSerie;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ColecaoSerieRepository implements PanacheRepository<ColecaoSerie> {

    public boolean existePorUsuarioESerie(Long usuarioId, Long serieId) {
        return find("usuario.id = ?1 and serie.id = ?2", usuarioId, serieId)
                .firstResultOptional()
                .isPresent();
    }

    public Optional<ColecaoSerie> buscarPorUsuarioESerie(Long usuarioId, Long serieId) {
        return find("usuario.id = ?1 and serie.id = ?2", usuarioId, serieId)
                .firstResultOptional();
    }
}
