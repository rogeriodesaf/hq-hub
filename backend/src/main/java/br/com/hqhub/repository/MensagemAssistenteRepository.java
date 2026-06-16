package br.com.hqhub.repository;

import java.util.List;

import br.com.hqhub.entity.MensagemAssistente;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class MensagemAssistenteRepository implements PanacheRepository<MensagemAssistente> {

    public List<MensagemAssistente> listarPorConversa(Long conversaId) {
        return list("conversa.id = ?1 order by dataCriacao asc, id asc", conversaId);
    }
}
