package br.com.hqhub.repository;

import java.util.Optional;

import br.com.hqhub.entity.CurtidaItemColecao;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class CurtidaItemColecaoRepository implements PanacheRepository<CurtidaItemColecao> {

    public Optional<CurtidaItemColecao> buscarPorItemEUsuario(Long itemColecaoId, Long usuarioId) {
        return find("itemColecao.id = ?1 and usuario.id = ?2", itemColecaoId, usuarioId).firstResultOptional();
    }

    public long contarPorItem(Long itemColecaoId) {
        return count("itemColecao.id", itemColecaoId);
    }

    public boolean existePorItemEUsuario(Long itemColecaoId, Long usuarioId) {
        return buscarPorItemEUsuario(itemColecaoId, usuarioId).isPresent();
    }
}
