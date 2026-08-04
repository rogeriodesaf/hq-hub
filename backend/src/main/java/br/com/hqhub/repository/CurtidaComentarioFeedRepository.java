package br.com.hqhub.repository;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

import br.com.hqhub.entity.CurtidaComentarioFeed;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class CurtidaComentarioFeedRepository implements PanacheRepository<CurtidaComentarioFeed> {

    public Optional<CurtidaComentarioFeed> buscarPorComentarioEUsuario(Long comentarioId, Long usuarioId) {
        return find("comentario.id = ?1 and usuario.id = ?2", comentarioId, usuarioId).firstResultOptional();
    }

    public Map<Long, Long> contarPorComentarios(List<Long> comentarioIds) {
        if (comentarioIds.isEmpty()) {
            return Map.of();
        }
        return getEntityManager().createQuery("""
                select curtida.comentario.id, count(curtida.id)
                from CurtidaComentarioFeed curtida
                where curtida.comentario.id in :comentarioIds
                group by curtida.comentario.id
                """, Object[].class)
                .setParameter("comentarioIds", comentarioIds)
                .getResultList()
                .stream()
                .collect(Collectors.toMap(resultado -> (Long) resultado[0], resultado -> (Long) resultado[1]));
    }

    public Set<Long> listarComentariosCurtidosPorUsuario(List<Long> comentarioIds, Long usuarioId) {
        if (comentarioIds.isEmpty()) {
            return Set.of();
        }
        return Set.copyOf(getEntityManager().createQuery("""
                select curtida.comentario.id
                from CurtidaComentarioFeed curtida
                where curtida.comentario.id in :comentarioIds and curtida.usuario.id = :usuarioId
                """, Long.class)
                .setParameter("comentarioIds", comentarioIds)
                .setParameter("usuarioId", usuarioId)
                .getResultList());
    }
}
