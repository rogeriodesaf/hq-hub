package br.com.hqhub.repository;

import java.util.Optional;
import java.util.UUID;

import br.com.hqhub.entity.ColetaGuia;
import io.quarkus.hibernate.orm.panache.PanacheRepositoryBase;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.persistence.LockModeType;

@ApplicationScoped
public class ColetaGuiaRepository implements PanacheRepositoryBase<ColetaGuia, UUID> {

    public Optional<ColetaGuia> buscarPorUsuario(UUID id, Long usuarioId) {
        return find("id = ?1 and usuario.id = ?2", id, usuarioId).firstResultOptional();
    }

    public Optional<ColetaGuia> buscarParaProcessamento(UUID id, Long usuarioId) {
        return find("id = ?1 and usuario.id = ?2", id, usuarioId)
                .withLock(LockModeType.PESSIMISTIC_WRITE)
                .firstResultOptional();
    }
}
