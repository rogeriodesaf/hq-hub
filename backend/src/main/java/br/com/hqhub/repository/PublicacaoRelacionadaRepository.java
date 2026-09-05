package br.com.hqhub.repository;

import java.util.List;

import br.com.hqhub.entity.PublicacaoRelacionada;
import br.com.hqhub.entity.TipoPublicacaoRelacionada;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class PublicacaoRelacionadaRepository implements PanacheRepository<PublicacaoRelacionada> {

    public List<PublicacaoRelacionada> listarPorEdicaoOrigem(Long origemId) {
        return find("edicaoOrigem.id = ?1 order by edicaoDestino.id", origemId).list();
    }

    public boolean existePorOrigemDestinoTipo(Long origemId, Long destinoId, TipoPublicacaoRelacionada tipo) {
        return find("edicaoOrigem.id = ?1 and edicaoDestino.id = ?2 and tipo = ?3", origemId, destinoId, tipo)
                .firstResultOptional()
                .isPresent();
    }
}
