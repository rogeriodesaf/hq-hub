package br.com.hqhub.repository;

import java.util.List;

import br.com.hqhub.entity.DenunciaUsuario;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class DenunciaUsuarioRepository implements PanacheRepository<DenunciaUsuario> {

    public List<DenunciaUsuario> listarPorDenunciante(Long denuncianteId) {
        return list("denunciante.id = ?1 order by dataCriacao desc", denuncianteId);
    }
}
