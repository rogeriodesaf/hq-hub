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
import io.quarkus.panache.common.Page;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class PostagemFeedRepository implements PanacheRepository<PostagemFeed> {

    public List<PostagemFeed> listarPorUsuario(Long perfilId, Long visitanteId, int pagina, int tamanho) {
        return find("""
                select p from PostagemFeed p where p.usuario.id = ?1
                and (
                    p.tipoPostagem <> ?3
                    or p.usuario.id = ?2
                    or exists (
                        select 1 from ConfiguracaoColecao c
                        where c.usuario.id = p.usuario.id and c.visibilidadeAtividades = ?4
                    )
                    or (
                        (
                            not exists (select 1 from ConfiguracaoColecao c where c.usuario.id = p.usuario.id)
                            or exists (
                                select 1 from ConfiguracaoColecao c
                                where c.usuario.id = p.usuario.id and c.visibilidadeAtividades = ?5
                            )
                        )
                        and p.usuario.id in (
                            select case when a.solicitante.id = ?2 then a.solicitado.id else a.solicitante.id end
                            from Amizade a
                            where (a.solicitante.id = ?2 or a.solicitado.id = ?2) and a.status = ?6
                        )
                    )
                )
                order by p.fixada desc, p.dataCriacao desc
                """, perfilId, visitanteId, TipoPostagemFeed.ATIVIDADE_ESTANTE,
                VisibilidadeColecao.PUBLICA, VisibilidadeColecao.AMIGOS, StatusAmizade.ACEITA)
                .page(Page.of(pagina, tamanho))
                .list();
    }

    public List<PostagemFeed> listarFeed(Long usuarioId, int pagina, int tamanho) {
        return find("""
                select p from PostagemFeed p where p.sistema = true or p.usuario.id = ?1
                or (
                    p.tipoPostagem <> ?3
                    and p.usuario.id in (
                        select case when a.solicitante.id = ?1 then a.solicitado.id else a.solicitante.id end
                        from Amizade a
                        where (a.solicitante.id = ?1 or a.solicitado.id = ?1) and a.status = ?2
                    )
                )
                or (
                    p.tipoPostagem = ?3
                    and (
                        exists (
                            select 1 from ConfiguracaoColecao c
                            where c.usuario.id = p.usuario.id and c.visibilidadeAtividades = ?4
                        )
                        or (
                            (
                                not exists (select 1 from ConfiguracaoColecao c where c.usuario.id = p.usuario.id)
                                or exists (
                                    select 1 from ConfiguracaoColecao c
                                    where c.usuario.id = p.usuario.id and c.visibilidadeAtividades = ?5
                                )
                            )
                            and p.usuario.id in (
                                select case when a.solicitante.id = ?1 then a.solicitado.id else a.solicitante.id end
                                from Amizade a
                                where (a.solicitante.id = ?1 or a.solicitado.id = ?1) and a.status = ?2
                            )
                        )
                    )
                )
                order by p.fixada desc, p.dataCriacao desc
                """, usuarioId, StatusAmizade.ACEITA, TipoPostagemFeed.ATIVIDADE_ESTANTE,
                VisibilidadeColecao.PUBLICA, VisibilidadeColecao.AMIGOS)
                .page(Page.of(pagina, tamanho))
                .list();
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
