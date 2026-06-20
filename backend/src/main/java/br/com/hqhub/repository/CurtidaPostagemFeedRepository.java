package br.com.hqhub.repository;

import java.util.Optional;

import br.com.hqhub.entity.CurtidaPostagemFeed;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class CurtidaPostagemFeedRepository implements PanacheRepository<CurtidaPostagemFeed> {

    public Optional<CurtidaPostagemFeed> buscarPorPostagemEUsuario(Long postagemId, Long usuarioId) {
        return find("postagem.id = ?1 and usuario.id = ?2", postagemId, usuarioId).firstResultOptional();
    }

    public long contarPorPostagem(Long postagemId) {
        return count("postagem.id", postagemId);
    }

    public boolean existePorPostagemEUsuario(Long postagemId, Long usuarioId) {
        return buscarPorPostagemEUsuario(postagemId, usuarioId).isPresent();
    }
}
