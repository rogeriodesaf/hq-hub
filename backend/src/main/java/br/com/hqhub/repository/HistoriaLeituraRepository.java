package br.com.hqhub.repository;

import java.time.LocalDateTime;
import java.util.List;
import br.com.hqhub.entity.HistoriaLeitura;
import br.com.hqhub.entity.StatusAmizade;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class HistoriaLeituraRepository implements PanacheRepository<HistoriaLeitura> {
    public List<HistoriaLeitura> listarExpiradas() {
        return list("dataExpiracao <= ?1", LocalDateTime.now());
    }

    public List<HistoriaLeitura> listarAtivas(Long usuarioId) {
        return getEntityManager().createNativeQuery("""
                select h.* from historias_leitura h
                join usuarios autor on autor.id = h.usuario_id
                where h.data_expiracao > :agora and (
                    h.usuario_id = :usuarioId
                    or lower(autor.email) = 'rogeriodesaf@gmail.com'
                    or autor.perfil = 'ADMINISTRADOR'
                    or h.usuario_id in (
                        select case when a.solicitante_id = :usuarioId then a.solicitado_id else a.solicitante_id end
                        from amizades a
                        where (a.solicitante_id = :usuarioId or a.solicitado_id = :usuarioId)
                          and a.status = :aceita
                    )
                )
                order by case when h.usuario_id = :usuarioId then 0 else 1 end, h.data_criacao asc
                """, HistoriaLeitura.class)
                .setParameter("agora", LocalDateTime.now())
                .setParameter("usuarioId", usuarioId)
                .setParameter("aceita", StatusAmizade.ACEITA.name())
                .getResultList();
    }
}
