package br.com.hqhub.repository;

import java.util.List;
import br.com.hqhub.entity.ComentarioHistoriaLeitura;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ComentarioHistoriaLeituraRepository implements PanacheRepository<ComentarioHistoriaLeitura> {
    public List<ComentarioHistoriaLeitura> listar(Long historiaId) { return list("historia.id = ?1 order by dataCriacao", historiaId); }
}
