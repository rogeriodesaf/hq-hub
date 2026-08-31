package br.com.hqhub.repository;

import java.util.List;
import java.util.Optional;

import br.com.hqhub.entity.ConteudoEdicao;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.persistence.EntityManager;

@ApplicationScoped
public class ConteudoEdicaoRepository implements PanacheRepository<ConteudoEdicao> {

    private final EntityManager entityManager;

    public ConteudoEdicaoRepository(EntityManager entityManager) {
        this.entityManager = entityManager;
    }

    public boolean existePorEdicaoEOrdem(Long edicaoId, Integer ordem) {
        return find("edicao.id = ?1 and ordem = ?2", edicaoId, ordem).firstResultOptional().isPresent();
    }

    public boolean existePorEdicaoEOrdemEmOutroConteudo(Long edicaoId, Integer ordem, Long conteudoId) {
        return find("edicao.id = ?1 and ordem = ?2 and id <> ?3", edicaoId, ordem, conteudoId)
                .firstResultOptional()
                .isPresent();
    }

    public List<ConteudoEdicao> listarPorEdicao(Long edicaoId) {
        return list("edicao.id = ?1 order by ordem asc", edicaoId);
    }

    public List<ConteudoEdicao> listarPorEdicaoComHistoria(Long edicaoId) {
        return entityManager.createQuery("""
                select conteudo
                 from ConteudoEdicao conteudo
                  join fetch conteudo.historia
                 where conteudo.edicao.id = :edicaoId
                   and conteudo.tipo = br.com.hqhub.entity.TipoConteudoEdicao.HISTORIA
                 order by conteudo.ordem asc
                """, ConteudoEdicao.class)
                .setParameter("edicaoId", edicaoId)
                .getResultList();
    }

    public Optional<ConteudoEdicao> buscarPrimeiroPorHistoria(Long historiaId) {
        return find("historia.id = ?1 order by ordem asc", historiaId).firstResultOptional();
    }

    public Optional<ConteudoEdicao> buscarPorEdicaoEHistoria(Long edicaoId, Long historiaId) {
        return find("edicao.id = ?1 and historia.id = ?2", edicaoId, historiaId).firstResultOptional();
    }

    public long contarPorEdicao(Long edicaoId) {
        return count("edicao.id", edicaoId);
    }
}
