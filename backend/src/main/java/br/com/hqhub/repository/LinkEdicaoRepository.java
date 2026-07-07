package br.com.hqhub.repository;

import java.util.Optional;

import br.com.hqhub.entity.LinkEdicao;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class LinkEdicaoRepository implements PanacheRepository<LinkEdicao> {

    public boolean existePorEdicaoEUrl(Long edicaoId, String url) {
        return buscarPorEdicaoEUrl(edicaoId, url)
                .isPresent();
    }

    public Optional<LinkEdicao> buscarPorEdicaoEUrl(Long edicaoId, String url) {
        return find("edicao.id = ?1 and url = ?2", edicaoId, url)
                .firstResultOptional()
                .map(LinkEdicao.class::cast);
    }

    public boolean existePorEdicaoEUrlEmOutroLink(Long edicaoId, String url, Long id) {
        return find("edicao.id = ?1 and url = ?2 and id <> ?3", edicaoId, url, id)
                .firstResultOptional()
                .isPresent();
    }
}
