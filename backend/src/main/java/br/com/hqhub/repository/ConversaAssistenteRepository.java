package br.com.hqhub.repository;

import java.util.List;

import br.com.hqhub.entity.ConversaAssistente;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ConversaAssistenteRepository implements PanacheRepository<ConversaAssistente> {

    public List<ConversaAssistente> listarPorUsuario(Long usuarioId) {
        return list("usuario.id = ?1 order by dataAtualizacao desc", usuarioId);
    }
}
