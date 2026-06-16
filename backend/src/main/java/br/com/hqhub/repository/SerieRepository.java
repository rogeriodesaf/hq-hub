package br.com.hqhub.repository;

import java.util.List;

import br.com.hqhub.entity.Serie;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.quarkus.panache.common.Page;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class SerieRepository implements PanacheRepository<Serie> {

    public boolean existePorTituloEEditora(String titulo, Long editoraId) {
        return find("lower(titulo) = ?1 and editora.id = ?2", titulo.toLowerCase(), editoraId)
                .firstResultOptional()
                .isPresent();
    }

    public boolean existePorTituloEEditoraEmOutraSerie(String titulo, Long editoraId, Long id) {
        return find("lower(titulo) = ?1 and editora.id = ?2 and id <> ?3", titulo.toLowerCase(), editoraId, id)
                .firstResultOptional()
                .isPresent();
    }

    public boolean existePorOrigemExterna(String fonteExterna, String idExterno) {
        if (fonteExterna == null || idExterno == null) {
            return false;
        }

        return find("fonteExterna = ?1 and idExterno = ?2", fonteExterna, idExterno)
                .firstResultOptional()
                .isPresent();
    }

    public boolean existePorOrigemExternaEmOutraSerie(String fonteExterna, String idExterno, Long id) {
        if (fonteExterna == null || idExterno == null) {
            return false;
        }

        return find("fonteExterna = ?1 and idExterno = ?2 and id <> ?3", fonteExterna, idExterno, id)
                .firstResultOptional()
                .isPresent();
    }

    public List<Serie> buscarPaginado(String busca, int pagina, int tamanho) {
        if (busca == null || busca.isBlank()) {
            return find("order by titulo").page(Page.of(pagina, tamanho)).list();
        }

        return find("lower(titulo) like ?1 order by titulo", "%" + busca.toLowerCase() + "%")
                .page(Page.of(pagina, tamanho))
                .list();
    }

    public long contarComBusca(String busca) {
        if (busca == null || busca.isBlank()) {
            return count();
        }

        return count("lower(titulo) like ?1", "%" + busca.toLowerCase() + "%");
    }
}
