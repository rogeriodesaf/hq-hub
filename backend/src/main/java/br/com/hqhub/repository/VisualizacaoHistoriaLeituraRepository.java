package br.com.hqhub.repository;

import java.util.List;

import br.com.hqhub.entity.VisualizacaoHistoriaLeitura;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class VisualizacaoHistoriaLeituraRepository implements PanacheRepository<VisualizacaoHistoriaLeitura> {
    public boolean visualizada(Long historiaId, Long usuarioId) {
        return count("historia.id = ?1 and usuario.id = ?2", historiaId, usuarioId) > 0;
    }

    public long total(Long historiaId) {
        return count("historia.id = ?1 and usuario.id <> historia.usuario.id", historiaId);
    }

    public List<VisualizacaoHistoriaLeitura> listarPorHistoria(Long historiaId) {
        return list("historia.id = ?1 and usuario.id <> historia.usuario.id order by dataVisualizacao desc", historiaId);
    }
}
