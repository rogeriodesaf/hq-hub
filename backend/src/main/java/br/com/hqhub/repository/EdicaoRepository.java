package br.com.hqhub.repository;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.Set;

import br.com.hqhub.entity.Edicao;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.quarkus.panache.common.Page;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class EdicaoRepository implements PanacheRepository<Edicao> {

    private static final Set<String> PALAVRAS_IGNORADAS = Set.of(
            "a", "as", "o", "os", "de", "da", "das", "do", "dos", "e",
            "colecao", "coleção", "edicao", "edição", "revista", "hq", "numero", "n");

    public boolean existePorNumeroESerie(String numero, Long serieId) {
        return find("lower(numero) = ?1 and serie.id = ?2", numero.toLowerCase(), serieId)
                .firstResultOptional()
                .isPresent();
    }

    public boolean existePorNumeroESerieEmOutraEdicao(String numero, Long serieId, Long id) {
        return find("lower(numero) = ?1 and serie.id = ?2 and id <> ?3", numero.toLowerCase(), serieId, id)
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

    public Optional<Edicao> buscarPorOrigemExterna(String fonteExterna, String idExterno) {
        if (fonteExterna == null || idExterno == null) {
            return Optional.empty();
        }

        return find("fonteExterna = ?1 and idExterno = ?2", fonteExterna, idExterno)
                .firstResultOptional();
    }

    public boolean existePorOrigemExternaEmOutraEdicao(String fonteExterna, String idExterno, Long id) {
        if (fonteExterna == null || idExterno == null) {
            return false;
        }

        return find("fonteExterna = ?1 and idExterno = ?2 and id <> ?3", fonteExterna, idExterno, id)
                .firstResultOptional()
                .isPresent();
    }

    public List<Edicao> buscarPaginado(Long serieId, String busca, int pagina, int tamanho) {
        List<String> termos = extrairTermosBusca(busca);
        if (serieId != null && !termos.isEmpty()) {
            List<Object> parametros = criarParametrosBusca(serieId, termos);
            return find(criarConsultaBusca(true, termos, "order by numero"), parametros.toArray())
                    .page(Page.of(pagina, tamanho))
                    .list();
        }

        if (serieId != null) {
            return find("serie.id = ?1 order by numero", serieId)
                    .page(Page.of(pagina, tamanho))
                    .list();
        }

        if (!termos.isEmpty()) {
            return find(criarConsultaBusca(false, termos, "order by serie.titulo, numero"), criarParametrosBusca(null, termos).toArray())
                    .page(Page.of(pagina, tamanho))
                    .list();
        }

        return find("order by numero").page(Page.of(pagina, tamanho)).list();
    }

    public List<Edicao> buscarTodosComBusca(Long serieId, String busca) {
        List<String> termos = extrairTermosBusca(busca);
        if (serieId != null && !termos.isEmpty()) {
            return find(criarConsultaBusca(true, termos, ""), criarParametrosBusca(serieId, termos).toArray())
                    .list();
        }

        if (serieId != null) {
            return find("serie.id", serieId).list();
        }

        if (!termos.isEmpty()) {
            return find(criarConsultaBusca(false, termos, ""), criarParametrosBusca(null, termos).toArray())
                    .list();
        }

        return listAll();
    }

    public long contarComBusca(Long serieId, String busca) {
        List<String> termos = extrairTermosBusca(busca);
        if (serieId != null && !termos.isEmpty()) {
            return count(criarConsultaBusca(true, termos, ""), criarParametrosBusca(serieId, termos).toArray());
        }

        if (serieId != null) {
            return count("serie.id", serieId);
        }

        if (!termos.isEmpty()) {
            return count(criarConsultaBusca(false, termos, ""), criarParametrosBusca(null, termos).toArray());
        }

        return count();
    }

    private String criarConsultaBusca(boolean filtrarSerie, List<String> termos, String ordenacao) {
        StringBuilder consulta = new StringBuilder();
        int indiceParametro = 1;

        if (filtrarSerie) {
            consulta.append("serie.id = ?1");
            indiceParametro = 2;
        }

        for (int i = 0; i < termos.size(); i++) {
            if (consulta.length() > 0) {
                consulta.append(" and ");
            }

            int parametro = indiceParametro + i;
            consulta.append("(lower(numero) like ?").append(parametro)
                    .append(" or lower(titulo) like ?").append(parametro)
                    .append(" or lower(descricao) like ?").append(parametro)
                    .append(" or lower(nomeVolume) like ?").append(parametro)
                    .append(" or lower(serie.titulo) like ?").append(parametro)
                    .append(" or lower(serie.descricao) like ?").append(parametro)
                    .append(" or lower(serie.editora.nome) like ?").append(parametro)
                    .append(")");
        }

        if (!ordenacao.isBlank()) {
            consulta.append(" ").append(ordenacao);
        }

        return consulta.toString();
    }

    private List<Object> criarParametrosBusca(Long serieId, List<String> termos) {
        List<Object> parametros = new ArrayList<>();
        if (serieId != null) {
            parametros.add(serieId);
        }

        termos.forEach(termo -> parametros.add("%" + termo + "%"));
        return parametros;
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
