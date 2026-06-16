package br.com.hqhub.repository;

import br.com.hqhub.entity.RelacionamentoSerie;
import br.com.hqhub.entity.TipoRelacionamentoSerie;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class RelacionamentoSerieRepository implements PanacheRepository<RelacionamentoSerie> {

    public boolean existePorOrigemDestinoTipo(Long origemId, Long destinoId, TipoRelacionamentoSerie tipo) {
        return find("serieOrigem.id = ?1 and serieDestino.id = ?2 and tipo = ?3", origemId, destinoId, tipo)
                .firstResultOptional()
                .isPresent();
    }
}
