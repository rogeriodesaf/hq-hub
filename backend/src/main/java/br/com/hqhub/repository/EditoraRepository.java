package br.com.hqhub.repository;

import java.util.Optional;

import br.com.hqhub.entity.Editora;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class EditoraRepository implements PanacheRepository<Editora> {

    public Optional<Editora> buscarPorNome(String nome) {
        return find("lower(nome)", nome.toLowerCase()).firstResultOptional();
    }

    public boolean existePorNome(String nome) {
        return buscarPorNome(nome).isPresent();
    }

    public boolean existePorNomeEmOutraEditora(String nome, Long id) {
        return find("lower(nome) = ?1 and id <> ?2", nome.toLowerCase(), id).firstResultOptional().isPresent();
    }

    public boolean existePorOrigemExterna(String fonteExterna, String idExterno) {
        if (fonteExterna == null || idExterno == null) {
            return false;
        }

        return find("fonteExterna = ?1 and idExterno = ?2", fonteExterna, idExterno)
                .firstResultOptional()
                .isPresent();
    }

    public boolean existePorOrigemExternaEmOutraEditora(String fonteExterna, String idExterno, Long id) {
        if (fonteExterna == null || idExterno == null) {
            return false;
        }

        return find("fonteExterna = ?1 and idExterno = ?2 and id <> ?3", fonteExterna, idExterno, id)
                .firstResultOptional()
                .isPresent();
    }
}
