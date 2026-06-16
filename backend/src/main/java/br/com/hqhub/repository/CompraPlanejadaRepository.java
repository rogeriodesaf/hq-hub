package br.com.hqhub.repository;

import br.com.hqhub.entity.CompraPlanejada;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class CompraPlanejadaRepository implements PanacheRepository<CompraPlanejada> {

    public boolean existePorUsuarioEdicaoMesAno(Long usuarioId, Long edicaoId, Integer mes, Integer ano) {
        return find("usuario.id = ?1 and edicao.id = ?2 and mes = ?3 and ano = ?4", usuarioId, edicaoId, mes, ano)
                .firstResultOptional()
                .isPresent();
    }
}
