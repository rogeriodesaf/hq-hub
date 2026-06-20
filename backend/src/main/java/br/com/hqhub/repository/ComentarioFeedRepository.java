package br.com.hqhub.repository;

import java.util.List;

import br.com.hqhub.entity.ComentarioFeed;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ComentarioFeedRepository implements PanacheRepository<ComentarioFeed> {

    public List<ComentarioFeed> listarPorPostagem(Long postagemId) {
        return list("postagem.id = ?1 order by dataCriacao", postagemId);
    }
}
