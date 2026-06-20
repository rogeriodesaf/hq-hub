package br.com.hqhub.repository;

import java.util.List;
import java.util.Optional;

import br.com.hqhub.entity.StatusLeitura;
import br.com.hqhub.entity.ItemColecao;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.persistence.EntityManager;

@ApplicationScoped
public class ItemColecaoRepository implements PanacheRepository<ItemColecao> {

    private final EntityManager entityManager;

    public ItemColecaoRepository(EntityManager entityManager) {
        this.entityManager = entityManager;
    }

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

    public Optional<ItemColecao> buscarPorUsuarioEOrigemExterna(Long usuarioId, String fonteExterna, String idExterno) {
        return find("usuario.id = ?1 and edicao.fonteExterna = ?2 and edicao.idExterno = ?3",
                usuarioId, fonteExterna, idExterno)
                .firstResultOptional();
    }

    public long contarPorUsuarioComFiltros(Long usuarioId, String busca, StatusLeitura statusLeitura) {
        StringBuilder jpql = new StringBuilder("""
                select count(item)
                  from ItemColecao item
                  join item.edicao edicao
                  join edicao.serie serie
                  join serie.editora editora
                 where item.usuario.id = :usuarioId
                """);
        adicionarFiltros(jpql, busca, statusLeitura);

        var consulta = entityManager.createQuery(jpql.toString(), Long.class)
                .setParameter("usuarioId", usuarioId);
        aplicarParametros(consulta, busca, statusLeitura);
        return consulta.getSingleResult();
    }

    public List<ItemColecao> buscarPorUsuarioPaginado(Long usuarioId, String busca, StatusLeitura statusLeitura, int pagina, int tamanho) {
        StringBuilder jpql = new StringBuilder("""
                select item
                  from ItemColecao item
                  join fetch item.edicao edicao
                  join fetch edicao.serie serie
                  join fetch serie.editora editora
                 where item.usuario.id = :usuarioId
                """);
        adicionarFiltros(jpql, busca, statusLeitura);
        jpql.append(" order by lower(editora.nome), lower(serie.titulo), lower(edicao.numero), item.id");

        var consulta = entityManager.createQuery(jpql.toString(), ItemColecao.class)
                .setParameter("usuarioId", usuarioId)
                .setFirstResult(pagina * tamanho)
                .setMaxResults(tamanho);
        aplicarParametros(consulta, busca, statusLeitura);
        return consulta.getResultList();
    }

    public List<ItemColecao> buscarPorUsuarioParaExportacao(Long usuarioId) {
        return entityManager.createQuery("""
                select item
                  from ItemColecao item
                  join fetch item.edicao edicao
                  join fetch edicao.serie serie
                  join fetch serie.editora editora
                 where item.usuario.id = :usuarioId
                 order by lower(editora.nome), lower(serie.titulo), lower(edicao.numero), item.id
                """, ItemColecao.class)
                .setParameter("usuarioId", usuarioId)
                .getResultList();
    }

    private void adicionarFiltros(StringBuilder jpql, String busca, StatusLeitura statusLeitura) {
        if (statusLeitura != null) {
            jpql.append(" and item.statusLeitura = :statusLeitura");
        }

        if (busca != null && !busca.isBlank()) {
            jpql.append("""
                     and (
                        lower(editora.nome) like :busca
                        or lower(serie.titulo) like :busca
                        or lower(edicao.numero) like :busca
                        or lower(coalesce(edicao.titulo, '')) like :busca
                     )
                    """);
        }
    }

    private void aplicarParametros(jakarta.persistence.Query consulta, String busca, StatusLeitura statusLeitura) {
        if (statusLeitura != null) {
            consulta.setParameter("statusLeitura", statusLeitura);
        }

        if (busca != null && !busca.isBlank()) {
            consulta.setParameter("busca", "%" + busca.trim().toLowerCase() + "%");
        }
    }
}
