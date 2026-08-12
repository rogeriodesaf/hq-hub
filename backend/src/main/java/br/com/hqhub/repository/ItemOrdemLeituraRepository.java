package br.com.hqhub.repository;

import java.util.List;
import br.com.hqhub.entity.ItemOrdemLeitura;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ItemOrdemLeituraRepository implements PanacheRepository<ItemOrdemLeitura> {
    public List<ItemOrdemLeitura> listar(Long ordemId) {
        return find("ordemLeitura.id = ?1 order by posicao", ordemId).list();
    }
}
