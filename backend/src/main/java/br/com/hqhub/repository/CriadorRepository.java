package br.com.hqhub.repository;

import br.com.hqhub.entity.Criador;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class CriadorRepository implements PanacheRepository<Criador> {

    public boolean existePorNome(String nome) {
        return find("lower(nome)", nome.toLowerCase()).firstResultOptional().isPresent();
    }

    public boolean existePorNomeEmOutroCriador(String nome, Long id) {
        return find("lower(nome) = ?1 and id <> ?2", nome.toLowerCase(), id).firstResultOptional().isPresent();
    }
}
