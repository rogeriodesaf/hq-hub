package br.com.hqhub.repository;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.Set;

import br.com.hqhub.entity.Edicao;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.quarkus.panache.common.Page;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.persistence.EntityManager;

@ApplicationScoped
public class EdicaoRepository implements PanacheRepository<Edicao> {

    private static final Set<String> STOPWORDS = Set.of(
            "a", "o", "os", "as",
            "de", "da", "do", "das", "dos",
            "e", "em", "na", "no", "nas", "nos",
            "para", "por", "com", "sem", "ao", "aos");

    private static final String ACENTOS = "áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ";
    private static final String SEM_ACENTOS = "aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC";

    private final EntityManager entityManager;

    public EdicaoRepository(EntityManager entityManager) {
        this.entityManager = entityManager;
    }

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
        if (busca == null || busca.isBlank()) {
            if (serieId != null) {
                return find("serie.id = ?1 order by numero", serieId).page(Page.of(pagina, tamanho)).list();
            }
            return find("order by serie.titulo, numero").page(Page.of(pagina, tamanho)).list();
        }

        ConsultaBusca consulta = montarConsultaBusca(busca);
        var query = entityManager.createNativeQuery(sqlBusca(serieId, consulta.termos(), false), Edicao.class);
        aplicarParametrosBusca(query, serieId, consulta);
        query.setFirstResult(pagina * tamanho);
        query.setMaxResults(tamanho);
        return query.getResultList();
    }

    public List<Edicao> buscarTodosComBusca(Long serieId, String busca) {
        if (busca == null || busca.isBlank()) {
            return serieId == null ? listAll() : find("serie.id", serieId).list();
        }

        ConsultaBusca consulta = montarConsultaBusca(busca);
        var query = entityManager.createNativeQuery(sqlBusca(serieId, consulta.termos(), false), Edicao.class);
        aplicarParametrosBusca(query, serieId, consulta);
        return query.getResultList();
    }

    public long contarComBusca(Long serieId, String busca) {
        if (busca == null || busca.isBlank()) {
            return serieId == null ? count() : count("serie.id", serieId);
        }

        ConsultaBusca consulta = montarConsultaBusca(busca);
        var query = entityManager.createNativeQuery(sqlBusca(serieId, consulta.termos(), true));
        aplicarParametrosBusca(query, serieId, consulta);
        Number total = (Number) query.getSingleResult();
        return total.longValue();
    }

    private String sqlBusca(Long serieId, List<String> termos, boolean contar) {
        String select = contar ? "select count(*)" : "select ed.*";
        String ordem = contar ? "" : " order by lower(s.titulo), lower(ed.numero), ed.id";
        String filtroSerie = serieId == null ? "" : " and s.id = :serieId";
        String condicaoBusca = construirCondicaoBusca(termos);

        return """
                %s
                  from edicoes ed
                  join series s on s.id = ed.serie_id
                  join editoras e on e.id = s.editora_id
                 where 1 = 1
                   %s
                   and (%s)
                %s
                """.formatted(
                select,
                filtroSerie,
                condicaoBusca,
                ordem);
    }

    private String construirCondicaoBusca(List<String> termos) {
        if (termos.isEmpty()) {
            return "(" + expressaoNormalizada("ed.numero") + " like :termoFallback"
                    + " or " + expressaoNormalizada("ed.titulo") + " like :termoFallback"
                    + " or " + expressaoNormalizada("ed.descricao") + " like :termoFallback"
                    + " or " + expressaoNormalizada("ed.nome_volume") + " like :termoFallback"
                    + " or " + expressaoNormalizada("s.titulo") + " like :termoFallback"
                    + " or " + expressaoNormalizada("e.nome") + " like :termoFallback" + ")";
        }

        List<String> grupos = new ArrayList<>();
        for (int i = 0; i < termos.size(); i++) {
            String parametro = ":termo" + i;
            grupos.add("("
                    + expressaoNormalizada("ed.numero") + " like " + parametro
                    + " or " + expressaoNormalizada("ed.titulo") + " like " + parametro
                    + " or " + expressaoNormalizada("ed.descricao") + " like " + parametro
                    + " or " + expressaoNormalizada("ed.nome_volume") + " like " + parametro
                    + " or " + expressaoNormalizada("s.titulo") + " like " + parametro
                    + " or " + expressaoNormalizada("e.nome") + " like " + parametro
                    + ")");
        }
        return String.join(" and ", grupos);
    }

    private String expressaoNormalizada(String coluna) {
        return "regexp_replace(lower(translate(coalesce(" + coluna + ", ''), '" + ACENTOS + "', '" + SEM_ACENTOS + "')), '[^a-z0-9]+', '', 'g')";
    }

    private String normalizarCompacto(String valor) {
        return Normalizer.normalize(valor.toLowerCase(Locale.ROOT), Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replaceAll("[^a-z0-9]+", "");
    }

    private void aplicarParametrosBusca(jakarta.persistence.Query query, Long serieId, ConsultaBusca consulta) {
        if (serieId != null) {
            query.setParameter("serieId", serieId);
        }

        if (consulta.termos().isEmpty()) {
            query.setParameter("termoFallback", "%" + consulta.termoFallback() + "%");
        }
        for (int i = 0; i < consulta.termos().size(); i++) {
            query.setParameter("termo" + i, "%" + consulta.termos().get(i) + "%");
        }
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
