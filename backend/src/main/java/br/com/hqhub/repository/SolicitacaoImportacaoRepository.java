package br.com.hqhub.repository;

import br.com.hqhub.entity.SolicitacaoImportacao;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class SolicitacaoImportacaoRepository implements PanacheRepository<SolicitacaoImportacao> {
}
