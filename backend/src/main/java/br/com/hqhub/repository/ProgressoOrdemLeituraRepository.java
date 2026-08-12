package br.com.hqhub.repository;

import java.util.List;
import br.com.hqhub.entity.ProgressoOrdemLeitura;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ProgressoOrdemLeituraRepository implements PanacheRepository<ProgressoOrdemLeitura> {
    public List<ProgressoOrdemLeitura> listar(Long usuarioId, Long ordemId) {
        return find("usuario.id = ?1 and item.ordemLeitura.id = ?2", usuarioId, ordemId).list();
    }
}
