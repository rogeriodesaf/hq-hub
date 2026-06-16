package br.com.hqhub.repository;

import java.util.List;

import br.com.hqhub.entity.DenunciaAnuncio;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class DenunciaAnuncioRepository implements PanacheRepository<DenunciaAnuncio> {

    public List<DenunciaAnuncio> listarPorDenunciante(Long denuncianteId) {
        return list("denunciante.id = ?1 order by dataCriacao desc", denuncianteId);
    }
}
