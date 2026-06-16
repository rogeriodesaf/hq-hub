package br.com.hqhub.repository;

import java.util.List;

import br.com.hqhub.entity.CreditoEdicao;
import br.com.hqhub.entity.PapelCriador;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class CreditoEdicaoRepository implements PanacheRepository<CreditoEdicao> {

    public boolean existePorEdicaoCriadorPapel(Long edicaoId, Long criadorId, PapelCriador papel) {
        return find("edicao.id = ?1 and criador.id = ?2 and papel = ?3", edicaoId, criadorId, papel)
                .firstResultOptional()
                .isPresent();
    }

    public List<CreditoEdicao> listarPorCriador(Long criadorId) {
        return list("criador.id", criadorId);
    }

    public List<CreditoEdicao> listarPorCriadorEPapel(Long criadorId, PapelCriador papel) {
        return list("criador.id = ?1 and papel = ?2", criadorId, papel);
    }
}
