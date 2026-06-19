package br.com.hqhub.repository;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.Set;

import br.com.hqhub.entity.Serie;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.quarkus.panache.common.Page;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class SerieRepository implements PanacheRepository<Serie> {

    private static final Set<String> PALAVRAS_IGNORADAS = Set.of(
            "a", "as", "o", "os", "de", "da", "das", "do", "dos", "e",
            "colecao", "coleção", "edicao", "edição", "revista", "hq", "numero", "n");

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
        List<String> termos = extrairTermosBusca(busca);
        if (termos.isEmpty()) {
            return find("order by titulo").page(Page.of(pagina, tamanho)).list();
        }

        return find(criarConsultaBusca(termos, "order by titulo"), criarParametrosBusca(termos).toArray())
                .page(Page.of(pagina, tamanho))
                .list();
    }

    public long contarComBusca(String busca) {
        List<String> termos = extrairTermosBusca(busca);
        if (termos.isEmpty()) {
            return count();
        }

        return count(criarConsultaBusca(termos, ""), criarParametrosBusca(termos).toArray());
    }

    private String criarConsultaBusca(List<String> termos, String ordenacao) {
        StringBuilder consulta = new StringBuilder();

        for (int i = 0; i < termos.size(); i++) {
            if (i > 0) {
                consulta.append(" and ");
            }

            consulta.append("(lower(titulo) like ?").append(i + 1)
                    .append(" or lower(descricao) like ?").append(i + 1)
                    .append(" or lower(editora.nome) like ?").append(i + 1)
                    .append(")");
        }

        if (!ordenacao.isBlank()) {
            consulta.append(" ").append(ordenacao);
        }

        return consulta.toString();
    }

    private List<Object> criarParametrosBusca(List<String> termos) {
        return termos.stream()
                .map(termo -> (Object) ("%" + termo + "%"))
                .toList();
    }

    private List<String> extrairTermosBusca(String busca) {
        if (busca == null || busca.isBlank()) {
            return List.of();
        }

        String texto = Normalizer.normalize(busca.toLowerCase(Locale.ROOT), Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replaceAll("[^a-z0-9]+", " ");

        List<String> termos = new ArrayList<>(Arrays.stream(texto.split("\\s+"))
                .map(String::trim)
                .filter(termo -> termo.length() >= 2)
                .filter(termo -> !PALAVRAS_IGNORADAS.contains(termo))
                .distinct()
                .toList());

        if (termos.isEmpty() && !texto.isBlank()) {
            termos.add(texto.trim());
        }

        return termos;
    }
}
