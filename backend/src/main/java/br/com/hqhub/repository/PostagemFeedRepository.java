package br.com.hqhub.repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import br.com.hqhub.entity.PostagemFeed;
import br.com.hqhub.entity.StatusAmizade;
import br.com.hqhub.entity.TipoAtividadeEstante;
import br.com.hqhub.entity.TipoPostagemFeed;
import br.com.hqhub.entity.VisibilidadeColecao;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class PostagemFeedRepository implements PanacheRepository<PostagemFeed> {

    public List<PostagemFeed> listarPorUsuario(Long perfilId, Long visitanteId, int pagina, int tamanho) {
        return getEntityManager().createNativeQuery("""
                select p.* from postagens_feed p where p.usuario_id = :perfilId
                and (
                    p.tipo_postagem <> :tipoAtividade
                    or p.usuario_id = :visitanteId
                    or exists (
                        select 1 from configuracoes_colecao c
                        where c.usuario_id = p.usuario_id and c.visibilidade_atividades = :publica
                    )
                    or (
                        (
                            not exists (select 1 from configuracoes_colecao c where c.usuario_id = p.usuario_id)
                            or exists (
                                select 1 from configuracoes_colecao c
                                where c.usuario_id = p.usuario_id and c.visibilidade_atividades = :amigos
                            )
                        )
                        and p.usuario_id in (
                            select case when a.solicitante_id = :visitanteId then a.solicitado_id else a.solicitante_id end
                            from amizades a
                            where (a.solicitante_id = :visitanteId or a.solicitado_id = :visitanteId)
                              and a.status = :aceita
                        )
                    )
                )
                order by p.fixada desc, p.data_criacao desc
                """, PostagemFeed.class)
                .setParameter("perfilId", perfilId)
                .setParameter("visitanteId", visitanteId)
                .setParameter("tipoAtividade", TipoPostagemFeed.ATIVIDADE_ESTANTE.name())
                .setParameter("publica", VisibilidadeColecao.PUBLICA.name())
                .setParameter("amigos", VisibilidadeColecao.AMIGOS.name())
                .setParameter("aceita", StatusAmizade.ACEITA.name())
                .setFirstResult(pagina * tamanho)
                .setMaxResults(tamanho)
                .getResultList();
    }

    public List<PostagemFeed> listarFeed(Long usuarioId, int pagina, int tamanho) {
        return getEntityManager().createNativeQuery("""
                select p.* from postagens_feed p where p.sistema = true or p.usuario_id = :usuarioId
                or (
                    p.tipo_postagem <> :tipoAtividade
                    and p.usuario_id in (
                        select case when a.solicitante_id = :usuarioId then a.solicitado_id else a.solicitante_id end
                        from amizades a
                        where (a.solicitante_id = :usuarioId or a.solicitado_id = :usuarioId)
                          and a.status = :aceita
                    )
                )
                or (
                    p.tipo_postagem = :tipoAtividade
                    and (
                        exists (
                            select 1 from configuracoes_colecao c
                            where c.usuario_id = p.usuario_id and c.visibilidade_atividades = :publica
                        )
                        or (
                            (
                                not exists (select 1 from configuracoes_colecao c where c.usuario_id = p.usuario_id)
                                or exists (
                                    select 1 from configuracoes_colecao c
                                    where c.usuario_id = p.usuario_id and c.visibilidade_atividades = :amigos
                                )
                            )
                            and p.usuario_id in (
                                select case when a.solicitante_id = :usuarioId then a.solicitado_id else a.solicitante_id end
                                from amizades a
                                where (a.solicitante_id = :usuarioId or a.solicitado_id = :usuarioId)
                                  and a.status = :aceita
                            )
                        )
                    )
                )
                order by p.fixada desc, p.data_criacao desc
                """, PostagemFeed.class)
                .setParameter("usuarioId", usuarioId)
                .setParameter("tipoAtividade", TipoPostagemFeed.ATIVIDADE_ESTANTE.name())
                .setParameter("aceita", StatusAmizade.ACEITA.name())
                .setParameter("publica", VisibilidadeColecao.PUBLICA.name())
                .setParameter("amigos", VisibilidadeColecao.AMIGOS.name())
                .setFirstResult(pagina * tamanho)
                .setMaxResults(tamanho)
                .getResultList();
    }

    public Optional<PostagemFeed> buscarGrupoRecente(
            Long usuarioId,
            TipoAtividadeEstante tipoAtividade,
            LocalDateTime desde) {
        return find("""
                usuario.id = ?1 and tipoPostagem = ?2 and tipoAtividade = ?3 and dataCriacao >= ?4
                order by dataCriacao desc
                """, usuarioId, TipoPostagemFeed.ATIVIDADE_ESTANTE, tipoAtividade, desde)
                .firstResultOptional();
    }
}
