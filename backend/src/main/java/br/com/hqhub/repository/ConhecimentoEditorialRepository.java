package br.com.hqhub.repository;

import java.util.List;

import br.com.hqhub.entity.ConhecimentoEditorial;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ConhecimentoEditorialRepository implements PanacheRepository<ConhecimentoEditorial> {

    public List<ConhecimentoEditorial> buscarPorTipo(String tipo) {
        return list("tipo", tipo);
    }

    public List<ConhecimentoEditorial> buscarPorTitulo(String titulo) {
        return list("LOWER(titulo) LIKE LOWER(?1)", "%" + titulo + "%");
    }

    public List<ConhecimentoEditorial> buscarPorTipoEConfianca(String tipo, String confianca) {
        return list("tipo = ?1 AND confianca = ?2", tipo, confianca);
    }

    public List<ConhecimentoEditorial> buscarPorOrigem(String origemDados) {
        return list("origemDados", origemDados);
    }

    public List<ConhecimentoEditorial> buscarRecentes(int limite) {
        return list("ORDER BY dataAtualizacao DESC")
                .page(0, limite)
                .list();
    }

    public List<ConhecimentoEditorial> buscarPorTags(String tag) {
        return list("LOWER(tags) LIKE LOWER(?1)", "%" + tag + "%");
    }
}
