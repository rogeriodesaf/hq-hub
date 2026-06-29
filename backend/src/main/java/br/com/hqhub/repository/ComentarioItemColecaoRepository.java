package br.com.hqhub.repository;

import java.util.List;

import br.com.hqhub.entity.ComentarioItemColecao;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ComentarioItemColecaoRepository implements PanacheRepository<ComentarioItemColecao> {

    public List<ComentarioItemColecao> listarPorItem(Long itemColecaoId) {
        return list("itemColecao.id = ?1 order by dataCriacao", itemColecaoId);
    }
}
