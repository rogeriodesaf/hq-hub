package br.com.hqhub.repository;

import java.util.List;

import br.com.hqhub.entity.FotoAnuncio;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class FotoAnuncioRepository implements PanacheRepository<FotoAnuncio> {

    public List<FotoAnuncio> listarPorAnuncio(Long anuncioId) {
        return list("anuncio.id = ?1 order by principal desc, dataCriacao asc", anuncioId);
    }
}
