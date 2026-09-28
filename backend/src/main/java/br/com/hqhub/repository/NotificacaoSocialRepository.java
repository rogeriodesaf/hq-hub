package br.com.hqhub.repository;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import br.com.hqhub.entity.NotificacaoSocial;
import br.com.hqhub.entity.TipoNotificacaoSocial;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class NotificacaoSocialRepository implements PanacheRepository<NotificacaoSocial> {
    public int distribuirPostagemAdministrativa(Long autorId, Long postagemId, String mensagem) {
        return getEntityManager().createNativeQuery("""
                INSERT INTO notificacoes_sociais (
                    destinatario_id, autor_id, tipo, postagem_id, mensagem, lida, data_criacao
                )
                SELECT u.id, :autorId, 'NOVA_POSTAGEM_ADMIN', :postagemId, :mensagem, FALSE, CURRENT_TIMESTAMP
                FROM usuarios u
                WHERE u.id <> :autorId
                ON CONFLICT (destinatario_id, postagem_id)
                    WHERE tipo = 'NOVA_POSTAGEM_ADMIN'
                DO UPDATE SET
                    autor_id = EXCLUDED.autor_id,
                    mensagem = EXCLUDED.mensagem,
                    lida = FALSE,
                    data_visualizacao = NULL,
                    data_criacao = CURRENT_TIMESTAMP
                """)
                .setParameter("autorId", autorId)
                .setParameter("postagemId", postagemId)
                .setParameter("mensagem", mensagem)
                .executeUpdate();
    }

    public List<NotificacaoSocial> listar(Long destinatarioId) {
        List<NotificacaoSocial> resultado = new ArrayList<>(find(
                "destinatario.id = ?1 and lida = false and tipo = ?2 order by dataCriacao desc",
                destinatarioId, TipoNotificacaoSocial.NOVA_POSTAGEM_ADMIN).list());
        resultado.addAll(find(
                "destinatario.id = ?1 and lida = false and tipo <> ?2 order by dataCriacao desc",
                destinatarioId, TipoNotificacaoSocial.NOVA_POSTAGEM_ADMIN).page(0, 40).list());
        resultado.sort(Comparator.comparing(NotificacaoSocial::getDataCriacao).reversed());
        return resultado;
    }
    public long contarNaoLidas(Long destinatarioId) {
        return count("destinatario.id = ?1 and lida = false", destinatarioId);
    }
    public void removerCurtidaPostagem(Long destinatarioId, Long autorId, Long postagemId) {
        delete("destinatario.id = ?1 and autor.id = ?2 and postagem.id = ?3 and tipo = ?4 and lida = true",
                destinatarioId, autorId, postagemId, TipoNotificacaoSocial.CURTIDA_POSTAGEM);
    }
    public void removerCurtidaComentario(Long destinatarioId, Long autorId, Long comentarioId) {
        delete("destinatario.id = ?1 and autor.id = ?2 and comentario.id = ?3 and tipo = ?4 and lida = true",
                destinatarioId, autorId, comentarioId, TipoNotificacaoSocial.CURTIDA_COMENTARIO);
    }

    public boolean existeCurtidaPostagem(Long destinatarioId, Long autorId, Long postagemId) {
        return count("destinatario.id = ?1 and autor.id = ?2 and postagem.id = ?3 and tipo = ?4",
                destinatarioId, autorId, postagemId, TipoNotificacaoSocial.CURTIDA_POSTAGEM) > 0;
    }

    public boolean existeCurtidaComentario(Long destinatarioId, Long autorId, Long comentarioId) {
        return count("destinatario.id = ?1 and autor.id = ?2 and comentario.id = ?3 and tipo = ?4",
                destinatarioId, autorId, comentarioId, TipoNotificacaoSocial.CURTIDA_COMENTARIO) > 0;
    }

}
