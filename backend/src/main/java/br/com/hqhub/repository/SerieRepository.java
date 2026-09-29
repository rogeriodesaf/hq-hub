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
import br.com.hqhub.entity.TipoSerie;
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
        return buscarTodasPorTituloEEditoraEVolume(titulo, editoraId, volume).stream().findFirst();
    }

    public List<Serie> buscarTodasPorTituloEEditoraEVolume(String titulo, Long editoraId, Integer volume) {
        if (titulo == null || editoraId == null) {
            return List.of();
        }

        // A mesma identidade usada pelo gatilho trg_bloquear_serie_duplicada.
        // Uma normalizacao apenas em Java pode divergir e tentar inserir uma serie ja existente.
        return entityManager.createNativeQuery("""
                        select s.* from series s
                         where s.editora_id = :editoraId
                           and coalesce(s.volume, 0) = :volume
                           and regexp_replace(hqhub_normalizar_titulo_serie(s.titulo), 'marvelsaga', '', 'g')
                               = regexp_replace(hqhub_normalizar_titulo_serie(:titulo), 'marvelsaga', '', 'g')
                         order by s.id
                        """, Serie.class)
                .setParameter("editoraId", editoraId)
                .setParameter("volume", volume == null ? 0 : volume)
                .setParameter("titulo", titulo)
                .getResultStream()
                .map(Serie.class::cast)
                .toList();
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
        return buscarPaginado(busca, inicial, pagina, tamanho, TipoSerie.BRASILEIRA);
    }

    public List<Serie> buscarPaginado(String busca, String inicial, int pagina, int tamanho, TipoSerie tipoSerie) {
        return buscarPaginado(busca, inicial, pagina, tamanho, tipoSerie, null);
    }

    public List<Serie> buscarPaginado(
            String busca, String inicial, int pagina, int tamanho, TipoSerie tipoSerie, Long editoraId) {
        if (busca == null || busca.isBlank()) {
            boolean filtrarInicial = inicialValida(inicial);
            StringBuilder filtro = new StringBuilder("tipoSerie = ?1");
            List<Object> parametros = new ArrayList<>();
            parametros.add(tipoSerie);
            if (editoraId != null) {
                filtro.append(" and editora.id = ?").append(parametros.size() + 1);
                parametros.add(editoraId);
            }
            if (filtrarInicial) {
                filtro.append(" and lower(titulo) like ?").append(parametros.size() + 1);
                parametros.add(inicial.toLowerCase(Locale.ROOT) + "%");
            }
            return find(filtro + " order by lower(titulo), volume, anoInicio, id", parametros.toArray())
                    .page(Page.of(pagina, tamanho))
                    .list();
        }

        ConsultaBusca consulta = montarConsultaBusca(busca);
        var query = entityManager.createNativeQuery(
                sqlBusca(inicial, consulta.termos(), false, editoraId != null), Serie.class);
        aplicarParametrosBusca(query, inicial, consulta, tipoSerie, editoraId);
        query.setFirstResult(pagina * tamanho);
        query.setMaxResults(tamanho);
        return query.getResultList();
    }

    public List<Serie> buscarPaginado(String busca, int pagina, int tamanho) {
        return buscarPaginado(busca, null, pagina, tamanho);
    }

    public long contarComBusca(String busca, String inicial) {
        return contarComBusca(busca, inicial, TipoSerie.BRASILEIRA);
    }

    public long contarComBusca(String busca, String inicial, TipoSerie tipoSerie) {
        return contarComBusca(busca, inicial, tipoSerie, null);
    }

    public long contarComBusca(String busca, String inicial, TipoSerie tipoSerie, Long editoraId) {
        if (busca == null || busca.isBlank()) {
            boolean filtrarInicial = inicialValida(inicial);
            StringBuilder filtro = new StringBuilder("tipoSerie = ?1");
            List<Object> parametros = new ArrayList<>();
            parametros.add(tipoSerie);
            if (editoraId != null) {
                filtro.append(" and editora.id = ?").append(parametros.size() + 1);
                parametros.add(editoraId);
            }
            if (filtrarInicial) {
                filtro.append(" and lower(titulo) like ?").append(parametros.size() + 1);
                parametros.add(inicial.toLowerCase(Locale.ROOT) + "%");
            }
            return count(filtro.toString(), parametros.toArray());
        }

        ConsultaBusca consulta = montarConsultaBusca(busca);
        var query = entityManager.createNativeQuery(
                sqlBusca(inicial, consulta.termos(), true, editoraId != null));
        aplicarParametrosBusca(query, inicial, consulta, tipoSerie, editoraId);
        Number total = (Number) query.getSingleResult();
        return total.longValue();
    }

    private String sqlBusca(String inicial, List<String> termos, boolean contar, boolean filtrarEditora) {
        String select = contar ? "select count(*)" : "select s.*";
        String ordem = contar ? "" : " order by lower(s.titulo), s.volume, s.ano_inicio, s.id";
        String busca = construirCondicaoBusca(termos);
        String filtroEditora = filtrarEditora ? " and s.editora_id = :editoraId" : "";

        return """
                %s
                 from series s
                  join editoras e on e.id = s.editora_id
                 where s.tipo_serie = :tipoSerie
                   %s
                   and (:inicial = '' or lower(s.titulo) like :inicialLike)
                   and (%s)
                %s
                """.formatted(select, filtroEditora, busca, ordem);
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

    private void aplicarParametrosBusca(
            jakarta.persistence.Query query, String inicial, ConsultaBusca consulta, TipoSerie tipoSerie, Long editoraId) {
        query.setParameter("tipoSerie", tipoSerie.name());
        if (editoraId != null) {
            query.setParameter("editoraId", editoraId);
        }
        query.setParameter("inicial", inicialValida(inicial) ? inicial.toLowerCase(Locale.ROOT) : "");
        query.setParameter("inicialLike", inicialValida(inicial) ? inicial.toLowerCase(Locale.ROOT) + "%" : "");
        if (consulta.termos().isEmpty()) {
            query.setParameter("termoFallback", "%" + consulta.termoFallback() + "%");
        }
        for (int i = 0; i < consulta.termos().size(); i++) {
            query.setParameter("termo" + i, "%" + consulta.termos().get(i) + "%");
        }
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
