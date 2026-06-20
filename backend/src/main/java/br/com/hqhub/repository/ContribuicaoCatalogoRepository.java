package br.com.hqhub.repository;

import java.time.LocalDateTime;
import java.util.List;

import br.com.hqhub.entity.ContribuicaoCatalogo;
import br.com.hqhub.entity.StatusContribuicaoCatalogo;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ContribuicaoCatalogoRepository implements PanacheRepository<ContribuicaoCatalogo> {

    public List<ContribuicaoCatalogo> listarPorUsuario(Long usuarioId) {
        return list("usuario.id = ?1 order by dataCriacao desc", usuarioId);
    }

    public List<ContribuicaoCatalogo> listarPendentes() {
        return list("status = ?1 order by dataCriacao asc", StatusContribuicaoCatalogo.PENDENTE);
    }

    public long contarPendentes() {
        return count("status", StatusContribuicaoCatalogo.PENDENTE);
    }

    public long contarAlteracoesEstantePorUsuarios(List<Long> usuarioIds, LocalDateTime desde) {
        if (usuarioIds == null || usuarioIds.isEmpty()) {
            return 0;
        }

        if (desde == null) {
            return count("usuario.id in ?1 and fonteExterna = ?2", usuarioIds, "ALTERACAO_ESTANTE");
        }

        return count("usuario.id in ?1 and fonteExterna = ?2 and dataCriacao > ?3",
                usuarioIds, "ALTERACAO_ESTANTE", desde);
    }

    public List<ContribuicaoCatalogo> listarAlteracoesEstantePorUsuarios(List<Long> usuarioIds, LocalDateTime desde) {
        if (usuarioIds == null || usuarioIds.isEmpty()) {
            return List.of();
        }

        if (desde == null) {
            return list("usuario.id in ?1 and fonteExterna = ?2 order by dataCriacao desc",
                    usuarioIds, "ALTERACAO_ESTANTE");
        }

        return list("usuario.id in ?1 and fonteExterna = ?2 and dataCriacao > ?3 order by dataCriacao desc",
                usuarioIds, "ALTERACAO_ESTANTE", desde);
    }
}
