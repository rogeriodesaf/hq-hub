package br.com.hqhub.repository;

import java.util.List;

import br.com.hqhub.entity.CapaEdicao;
import br.com.hqhub.entity.StatusCapaEdicao;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class CapaEdicaoRepository implements PanacheRepository<CapaEdicao> {

    public List<CapaEdicao> listarPorEdicao(Long edicaoId) {
        return list("edicao.id = ?1 order by dataEnvio desc, id desc", edicaoId);
    }

    public List<CapaEdicao> listarAprovadasPorEdicao(Long edicaoId) {
        return list("edicao.id = ?1 and status = ?2", edicaoId, StatusCapaEdicao.APROVADA);
    }
}
