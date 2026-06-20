package br.com.hqhub.repository;

import java.util.List;

import br.com.hqhub.entity.MensagemDireta;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class MensagemDiretaRepository implements PanacheRepository<MensagemDireta> {

    public List<MensagemDireta> listarDoUsuario(Long usuarioId) {
        return list("remetente.id = ?1 or destinatario.id = ?1 order by dataCriacao desc", usuarioId);
    }

    public List<MensagemDireta> listarConversa(Long usuarioId, Long outroUsuarioId) {
        return list("((remetente.id = ?1 and destinatario.id = ?2) or (remetente.id = ?2 and destinatario.id = ?1)) order by dataCriacao asc",
                usuarioId, outroUsuarioId);
    }

    public long contarNaoLidas(Long usuarioId) {
        return count("destinatario.id = ?1 and lida = false", usuarioId);
    }

    public long contarNaoLidasNaConversa(Long usuarioId, Long remetenteId) {
        return count("destinatario.id = ?1 and remetente.id = ?2 and lida = false", usuarioId, remetenteId);
    }
}
