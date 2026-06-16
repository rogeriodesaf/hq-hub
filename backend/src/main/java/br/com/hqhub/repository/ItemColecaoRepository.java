package br.com.hqhub.repository;

import java.util.List;

import br.com.hqhub.entity.ItemColecao;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ItemColecaoRepository implements PanacheRepository<ItemColecao> {

    public boolean existePorUsuarioEEdicao(Long usuarioId, Long edicaoId) {
        return find("usuario.id = ?1 and edicao.id = ?2", usuarioId, edicaoId)
                .firstResultOptional()
                .isPresent();
    }

    public List<Long> listarIdsEdicoesPorUsuarioESerie(Long usuarioId, Long serieId) {
        return find("select item.edicao.id from ItemColecao item where item.usuario.id = ?1 and item.edicao.serie.id = ?2",
                usuarioId, serieId)
                .project(Long.class)
                .list();
    }
}
