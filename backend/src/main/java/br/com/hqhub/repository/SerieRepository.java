package br.com.hqhub.repository;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.Set;

import br.com.hqhub.entity.Serie;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.quarkus.panache.common.Page;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.persistence.EntityManager;

@ApplicationScoped
public class SerieRepository implements PanacheRepository<Serie> {

    private static final Set<String> STOPWORDS = Set.of(
            "a", "o", "os", "as",
            "de", "da", "do", "das", "dos",
            "e", "em", "na", "no", "nas", "nos",
            "para", "por", "com", "sem", "ao", "aos");

    private static final String ACENTOS = "áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ";
    private static final String SEM_ACENTOS = "aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC";

    private final EntityManager entityManager;

    public SerieRepository(EntityManager entityManager) {
        this.entityManager = entityManager;
    }

    public boolean existePorTituloEEditoraEVolume(String titulo, Long editoraId, Integer volume) {
        return buscarPorTituloEEditoraEVolume(titulo, editoraId, volume).isPresent();
    }

    public boolean existePorTituloEEditoraEVolumeEmOutraSerie(String titulo, Long editoraId, Integer volume, Long id) {
        return buscarPorTituloEEditoraEVolume(titulo, editoraId, volume)
                .filter(serie -> !serie.getId().equals(id))
                .isPresent();
    }

    public Optional<Serie> buscarPorTituloEEditoraEVolume(String titulo, Long editoraId, Integer volume) {
        if (titulo == null || editoraId == null) {
            return Optional.empty();
        }

        int volumeNormalizado = volume == null ? 0 : volume;
        String tituloNormalizado = normalizarTituloIdentidade(titulo);
        return find("editora.id = ?1 and coalesce(volume, 0) = ?2", editoraId, volumeNormalizado)
                .stream()
                .filter(serie -> normalizarTituloIdentidade(serie.getTitulo()).equals(tituloNormalizado))
                .findFirst();
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

    public List<Serie> buscarPaginado(String busca, String inicial, int pagina, int tamanho) {
        if (busca == null || busca.isBlank()) {
            return find(consultaInicial(inicial, "order by lower(titulo), volume, anoInicio, id"), parametrosInicial(inicial))
                    .page(Page.of(pagina, tamanho))
                    .list();
        }

        ConsultaBusca consulta = montarConsultaBusca(busca);
        var query = entityManager.createNativeQuery(sqlBusca(inicial, consulta.termos(), false), Serie.class);
        aplicarParametrosBusca(query, inicial, consulta);
        query.setFirstResult(pagina * tamanho);
        query.setMaxResults(tamanho);
        return query.getResultList();
    }

    public List<Serie> buscarPaginado(String busca, int pagina, int tamanho) {
        return buscarPaginado(busca, null, pagina, tamanho);
    }

    public long contarComBusca(String busca, String inicial) {
        if (busca == null || busca.isBlank()) {
            return count(consultaInicial(inicial, ""), parametrosInicial(inicial));
        }

        ConsultaBusca consulta = montarConsultaBusca(busca);
        var query = entityManager.createNativeQuery(sqlBusca(inicial, consulta.termos(), true));
        aplicarParametrosBusca(query, inicial, consulta);
        Number total = (Number) query.getSingleResult();
        return total.longValue();
    }

    private String sqlBusca(String inicial, List<String> termos, boolean contar) {
        String select = contar ? "select count(*)" : "select s.*";
        String ordem = contar ? "" : " order by lower(s.titulo), s.volume, s.ano_inicio, s.id";
        String busca = construirCondicaoBusca(termos);

        return """
                %s
                  from series s
                  join editoras e on e.id = s.editora_id
                 where (:inicial = '' or lower(s.titulo) like :inicialLike)
                   and (%s)
                %s
                """.formatted(select, busca, ordem);
    }

    private String construirCondicaoBusca(List<String> termos) {
        if (termos.isEmpty()) {
            return "(" + expressaoNormalizada("s.titulo") + " like :termoFallback"
                    + " or " + expressaoNormalizada("s.descricao") + " like :termoFallback"
                    + " or " + expressaoNormalizada("e.nome") + " like :termoFallback" + ")";
        }

        List<String> grupos = new ArrayList<>();
        for (int i = 0; i < termos.size(); i++) {
            String parametro = ":termo" + i;
            grupos.add("("
                    + expressaoNormalizada("s.titulo") + " like " + parametro
                    + " or " + expressaoNormalizada("s.descricao") + " like " + parametro
                    + " or " + expressaoNormalizada("e.nome") + " like " + parametro
                    + ")");
        }
        return String.join(" and ", grupos);
    }

    private void aplicarParametrosBusca(jakarta.persistence.Query query, String inicial, ConsultaBusca consulta) {
        query.setParameter("inicial", inicialValida(inicial) ? inicial.toLowerCase(Locale.ROOT) : "");
        query.setParameter("inicialLike", inicialValida(inicial) ? inicial.toLowerCase(Locale.ROOT) + "%" : "");
        if (consulta.termos().isEmpty()) {
            query.setParameter("termoFallback", "%" + consulta.termoFallback() + "%");
        }
        for (int i = 0; i < consulta.termos().size(); i++) {
            query.setParameter("termo" + i, "%" + consulta.termos().get(i) + "%");
        }
    }

    private String consultaInicial(String inicial, String ordenacao) {
        if (!inicialValida(inicial)) {
            return ordenacao.isBlank() ? "1 = 1" : ordenacao;
        }

        return "lower(titulo) like ?1 " + ordenacao;
    }

    private Object[] parametrosInicial(String inicial) {
        return inicialValida(inicial) ? new Object[] { inicial.toLowerCase(Locale.ROOT) + "%" } : new Object[] {};
    }

    private boolean inicialValida(String inicial) {
        return inicial != null && inicial.matches("(?i)[a-z0-9]");
    }

    private String expressaoNormalizada(String coluna) {
        return "regexp_replace(lower(translate(coalesce(" + coluna + ", ''), '" + ACENTOS + "', '" + SEM_ACENTOS + "')), '[^a-z0-9]+', '', 'g')";
    }

    private String normalizarCompacto(String valor) {
        return Normalizer.normalize(valor.toLowerCase(Locale.ROOT), Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replaceAll("[^a-z0-9]+", "");
    }

    private String normalizarTituloIdentidade(String valor) {
        String[] bruto = Normalizer.normalize(valor.toLowerCase(Locale.ROOT), Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .split("[^a-z0-9]+");
        List<String> termos = new ArrayList<>();
        for (String termo : bruto) {
            if (!termo.isBlank()) {
                termos.add(termo);
            }
        }

        while (!termos.isEmpty() && ehArtigo(termos.get(0))) {
            termos.remove(0);
        }
        while (!termos.isEmpty() && ehArtigo(termos.get(termos.size() - 1))) {
            termos.remove(termos.size() - 1);
        }

        return String.join("", termos);
    }

    private boolean ehArtigo(String valor) {
        return "a".equals(valor) || "as".equals(valor) || "o".equals(valor) || "os".equals(valor);
    }

    private ConsultaBusca montarConsultaBusca(String busca) {
        String termoFallback = normalizarCompacto(busca);
        List<String> termos = tokenizarBusca(busca).stream()
                .map(this::normalizarCompacto)
                .filter(termo -> !termo.isBlank())
                .toList();
        if (termos.isEmpty()) {
            termos = Collections.singletonList(termoFallback);
        }
        return new ConsultaBusca(termos, termoFallback);
    }

    private List<String> tokenizarBusca(String busca) {
        String[] bruto = Normalizer.normalize(busca, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .toLowerCase(Locale.ROOT)
                .split("[^a-z0-9]+");
        List<String> termos = new ArrayList<>();
        for (String termo : bruto) {
            if (termo.length() >= 2 && !STOPWORDS.contains(termo)) {
                termos.add(termo);
            }
        }
        return new ArrayList<>(new LinkedHashSet<>(termos));
    }

    private record ConsultaBusca(List<String> termos, String termoFallback) {}
}
