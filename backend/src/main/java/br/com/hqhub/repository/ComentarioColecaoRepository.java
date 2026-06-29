package br.com.hqhub.repository;

import java.util.List;

import br.com.hqhub.entity.ComentarioColecao;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ComentarioColecaoRepository implements PanacheRepository<ComentarioColecao> {

    public List<ComentarioColecao> listarPorColecao(Long donoColecaoId) {
        return list("donoColecao.id = ?1 order by dataCriacao", donoColecaoId);
    }
}
