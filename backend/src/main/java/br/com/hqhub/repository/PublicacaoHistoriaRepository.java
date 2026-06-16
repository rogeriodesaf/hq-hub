package br.com.hqhub.repository;

import java.util.List;

import br.com.hqhub.entity.PublicacaoHistoria;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class PublicacaoHistoriaRepository implements PanacheRepository<PublicacaoHistoria> {

    public boolean existePorHistoriaEEdicaoPublicada(Long historiaId, Long edicaoPublicadaId) {
        return find("historia.id = ?1 and edicaoPublicada.id = ?2", historiaId, edicaoPublicadaId)
                .firstResultOptional()
                .isPresent();
    }

    public List<PublicacaoHistoria> listarPorHistoria(Long historiaId) {
        return list("historia.id = ?1 order by edicaoPublicada.dataPublicacao asc", historiaId);
    }

    public List<PublicacaoHistoria> listarPorEdicaoOriginalEPublicada(Long edicaoOriginalId, Long edicaoPublicadaId) {
        return list("edicaoOriginal.id = ?1 and edicaoPublicada.id = ?2 order by historia.titulo asc",
                edicaoOriginalId, edicaoPublicadaId);
    }
}
