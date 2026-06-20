package br.com.hqhub.repository;

import java.util.List;

import br.com.hqhub.entity.ImagemPostagemFeed;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ImagemPostagemFeedRepository implements PanacheRepository<ImagemPostagemFeed> {

    public List<ImagemPostagemFeed> listarPorPostagem(Long postagemId) {
        return list("postagem.id = ?1 order by ordem, id", postagemId);
    }
}
