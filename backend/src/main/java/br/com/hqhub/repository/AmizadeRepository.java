package br.com.hqhub.repository;

import java.util.List;
import java.util.Optional;

import br.com.hqhub.entity.Amizade;
import br.com.hqhub.entity.StatusAmizade;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class AmizadeRepository implements PanacheRepository<Amizade> {

    public Optional<Amizade> buscarEntreUsuarios(Long usuarioId, Long outroUsuarioId) {
        return find("(solicitante.id = ?1 and solicitado.id = ?2) or (solicitante.id = ?2 and solicitado.id = ?1)",
                usuarioId, outroUsuarioId)
                .firstResultOptional();
    }

    public boolean existeEntreUsuarios(Long usuarioId, Long outroUsuarioId) {
        return buscarEntreUsuarios(usuarioId, outroUsuarioId).isPresent();
    }

    public boolean saoAmigos(Long usuarioId, Long outroUsuarioId) {
        return find("((solicitante.id = ?1 and solicitado.id = ?2) or (solicitante.id = ?2 and solicitado.id = ?1)) and status = ?3",
                usuarioId, outroUsuarioId, StatusAmizade.ACEITA)
                .firstResultOptional()
                .isPresent();
    }

    public List<Amizade> listarAmigos(Long usuarioId) {
        return list("(solicitante.id = ?1 or solicitado.id = ?1) and status = ?2 order by dataResposta desc",
                usuarioId, StatusAmizade.ACEITA);
    }

    public List<Amizade> listarPendentesRecebidas(Long usuarioId) {
        return list("solicitado.id = ?1 and status = ?2 order by dataSolicitacao desc", usuarioId, StatusAmizade.PENDENTE);
    }

    public List<Amizade> listarPendentesEnviadas(Long usuarioId) {
        return list("solicitante.id = ?1 and status = ?2 order by dataSolicitacao desc", usuarioId, StatusAmizade.PENDENTE);
    }
}
