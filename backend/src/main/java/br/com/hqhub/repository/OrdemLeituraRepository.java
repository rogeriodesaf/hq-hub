package br.com.hqhub.repository;

import br.com.hqhub.entity.OrdemLeitura;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class OrdemLeituraRepository implements PanacheRepository<OrdemLeitura> {
}
