package br.com.hqhub.repository;

import java.util.List;

import br.com.hqhub.entity.VideoRelacionadoFeed;
import io.quarkus.hibernate.orm.panache.PanacheRepositoryBase;
import io.quarkus.panache.common.Page;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class VideoRelacionadoFeedRepository implements PanacheRepositoryBase<VideoRelacionadoFeed, java.util.UUID> {

    public List<VideoRelacionadoFeed> listarPorPostagem(Long postagemId) {
        return find("postagem.id = ?1 order by ordem asc", postagemId)
                .page(Page.ofSize(3))
                .list();
    }

    public void removerPorPostagem(Long postagemId) {
        delete("postagem.id", postagemId);
    }
}
