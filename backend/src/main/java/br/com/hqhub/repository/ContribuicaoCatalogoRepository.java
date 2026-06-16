package br.com.hqhub.repository;

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
}
