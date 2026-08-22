package br.com.hqhub.repository;

import java.util.List;

import br.com.hqhub.entity.EdicaoAtividadeEstante;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class EdicaoAtividadeEstanteRepository implements PanacheRepository<EdicaoAtividadeEstante> {
    public List<EdicaoAtividadeEstante> listarPorPostagem(Long postagemId) {
        return list("postagem.id = ?1 order by dataCriacao, id", postagemId);
    }

    public boolean existe(Long postagemId, Long edicaoId) {
        return count("postagem.id = ?1 and edicao.id = ?2", postagemId, edicaoId) > 0;
    }
}
