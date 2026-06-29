package br.com.hqhub.repository;

import java.util.Optional;

import br.com.hqhub.entity.CurtidaColecao;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class CurtidaColecaoRepository implements PanacheRepository<CurtidaColecao> {

    public Optional<CurtidaColecao> buscarPorColecaoEUsuario(Long donoColecaoId, Long usuarioId) {
        return find("donoColecao.id = ?1 and usuario.id = ?2", donoColecaoId, usuarioId).firstResultOptional();
    }

    public long contarPorColecao(Long donoColecaoId) {
        return count("donoColecao.id", donoColecaoId);
    }

    public boolean existePorColecaoEUsuario(Long donoColecaoId, Long usuarioId) {
        return buscarPorColecaoEUsuario(donoColecaoId, usuarioId).isPresent();
    }
}
