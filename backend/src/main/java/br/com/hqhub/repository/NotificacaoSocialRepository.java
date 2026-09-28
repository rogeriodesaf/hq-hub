package br.com.hqhub.repository;

import java.time.LocalDateTime;
import java.util.List;
import br.com.hqhub.entity.NotificacaoSocial;
import br.com.hqhub.entity.TipoNotificacaoSocial;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class NotificacaoSocialRepository implements PanacheRepository<NotificacaoSocial> {
    public List<NotificacaoSocial> listar(Long destinatarioId, LocalDateTime limiteLidas) {
        return find("destinatario.id = ?1 and (lida = false or dataVisualizacao >= ?2) order by dataCriacao desc",
                destinatarioId, limiteLidas).page(0, 40).list();
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

    public long removerLidasAntesDe(LocalDateTime limite) {
        return delete("lida = true and dataVisualizacao < ?1", limite);
    }
}
