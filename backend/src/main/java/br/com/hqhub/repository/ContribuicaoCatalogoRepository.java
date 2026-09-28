package br.com.hqhub.repository;

import java.time.LocalDateTime;
import java.util.List;

import br.com.hqhub.entity.ContribuicaoCatalogo;
import br.com.hqhub.entity.StatusContribuicaoCatalogo;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ContribuicaoCatalogoRepository implements PanacheRepository<ContribuicaoCatalogo> {

    public List<ContribuicaoCatalogo> listarPorUsuario(Long usuarioId) {
        return list("usuario.id = ?1 order by dataCriacao desc", usuarioId);
    }

    public List<ContribuicaoCatalogo> listarPendentes() {
        return list("status = ?1 order by dataCriacao asc", StatusContribuicaoCatalogo.PENDENTE);
    }

    public long contarPendentes() {
        return count("status", StatusContribuicaoCatalogo.PENDENTE);
    }

    public long contarAlteracoesEstantePorUsuarios(Long destinatarioId, List<Long> usuarioIds, LocalDateTime desde) {
        if (usuarioIds == null || usuarioIds.isEmpty()) {
            return 0;
        }

        String filtroDesde = desde == null ? "" : " AND c.data_criacao > :desde";
        String sql = """
                SELECT COUNT(*) FROM contribuicoes_catalogo c
                WHERE c.usuario_id IN (:usuarioIds)
                  AND c.fonte_externa = 'ALTERACAO_ESTANTE'
                  AND NOT EXISTS (
                    SELECT 1 FROM visualizacoes_alteracoes_estante v
                    WHERE v.usuario_id = :destinatarioId AND v.contribuicao_id = c.id
                  )
                """ + filtroDesde;
        var query = getEntityManager().createNativeQuery(sql)
                .setParameter("usuarioIds", usuarioIds)
                .setParameter("destinatarioId", destinatarioId);
        if (desde != null) query.setParameter("desde", desde);
        Number total = (Number) query.getSingleResult();
        return total.longValue();
    }

    public List<ContribuicaoCatalogo> listarAlteracoesEstantePorUsuarios(
            Long destinatarioId, List<Long> usuarioIds, LocalDateTime desde) {
        if (usuarioIds == null || usuarioIds.isEmpty()) {
            return List.of();
        }

        String filtroDesde = desde == null ? "" : " AND c.data_criacao > :desde";
        String sql = """
                SELECT c.* FROM contribuicoes_catalogo c
                WHERE c.usuario_id IN (:usuarioIds)
                  AND c.fonte_externa = 'ALTERACAO_ESTANTE'
                  AND NOT EXISTS (
                    SELECT 1 FROM visualizacoes_alteracoes_estante v
                    WHERE v.usuario_id = :destinatarioId AND v.contribuicao_id = c.id
                  )
                """ + filtroDesde + " ORDER BY c.data_criacao DESC";
        var query = getEntityManager().createNativeQuery(sql, ContribuicaoCatalogo.class)
                .setParameter("usuarioIds", usuarioIds)
                .setParameter("destinatarioId", destinatarioId);
        if (desde != null) query.setParameter("desde", desde);
        return query.getResultList();
    }

    public void marcarAlteracaoEstanteComoVisualizada(Long destinatarioId, Long contribuicaoId) {
        String sql = """
                INSERT INTO visualizacoes_alteracoes_estante (usuario_id, contribuicao_id, data_visualizacao)
                SELECT :destinatarioId, c.id, CURRENT_TIMESTAMP
                FROM contribuicoes_catalogo c
                WHERE c.id = :contribuicaoId
                  AND c.fonte_externa = 'ALTERACAO_ESTANTE'
                  AND EXISTS (
                    SELECT 1 FROM amizades a
                    WHERE a.status = 'ACEITA'
                      AND ((a.solicitante_id = :destinatarioId AND a.solicitado_id = c.usuario_id)
                        OR (a.solicitado_id = :destinatarioId AND a.solicitante_id = c.usuario_id))
                  )
                ON CONFLICT (usuario_id, contribuicao_id) DO NOTHING
                """;
        getEntityManager().createNativeQuery(sql)
                .setParameter("destinatarioId", destinatarioId)
                .setParameter("contribuicaoId", contribuicaoId)
                .executeUpdate();
    }
}
