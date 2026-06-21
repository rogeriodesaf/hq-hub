package br.com.hqhub.repository;

import java.util.List;

import br.com.hqhub.entity.PostagemFeed;
import br.com.hqhub.entity.StatusAmizade;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.quarkus.panache.common.Page;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class PostagemFeedRepository implements PanacheRepository<PostagemFeed> {

    public List<PostagemFeed> listarPorUsuario(Long usuarioId, int pagina, int tamanho) {
        return find("usuario.id = ?1 order by dataCriacao desc", usuarioId)
                .page(Page.of(pagina, tamanho))
                .list();
    }

    public List<PostagemFeed> listarFeed(Long usuarioId, int pagina, int tamanho) {
        return find("""
                usuario.id = ?1
                or usuario.id in (
                    select case
                        when a.solicitante.id = ?1 then a.solicitado.id
                        else a.solicitante.id
                    end
                    from Amizade a
                    where (a.solicitante.id = ?1 or a.solicitado.id = ?1)
                      and a.status = ?2
                )
                order by dataCriacao desc
                """, usuarioId, StatusAmizade.ACEITA)
                .page(Page.of(pagina, tamanho))
                .list();
    }
}
