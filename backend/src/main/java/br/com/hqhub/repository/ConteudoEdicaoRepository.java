package br.com.hqhub.repository;

import java.util.List;

import br.com.hqhub.entity.ConteudoEdicao;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ConteudoEdicaoRepository implements PanacheRepository<ConteudoEdicao> {

    public boolean existePorEdicaoEOrdem(Long edicaoId, Integer ordem) {
        return find("edicao.id = ?1 and ordem = ?2", edicaoId, ordem).firstResultOptional().isPresent();
    }

    public List<ConteudoEdicao> listarPorEdicao(Long edicaoId) {
        return list("edicao.id = ?1 order by ordem asc", edicaoId);
    }
}
