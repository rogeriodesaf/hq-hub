package br.com.hqhub.resource;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Path("/diagnostico")
@Produces(MediaType.APPLICATION_JSON)
public class DiagnosticoResource {

    @Inject
    EntityManager entityManager;

    private static final String VERSAO_BACKEND = "feed-premium-2026-08-05";

    @GET
    @Path("/versao")
    public VersaoResposta versao() {
        return new VersaoResposta(VERSAO_BACKEND, LocalDateTime.now());
    }

    @GET
    @Path("/capas-batman-abril")
    public Map<String, Object> capasBatmanAbril() {
        @SuppressWarnings("unchecked")
        List<Object[]> registros = entityManager.createNativeQuery("""
                SELECT s.id, s.titulo, s.volume, s.descricao, e.nome,
                       ed.id, ed.numero, ed.url_capa
                  FROM series s
                  JOIN editoras e ON e.id = s.editora_id
                  LEFT JOIN edicoes ed ON ed.serie_id = s.id
                 WHERE hqhub_normalizar_titulo_serie(e.nome) LIKE '%abril%'
                   AND hqhub_normalizar_titulo_serie(s.titulo) LIKE '%batman%'
                   AND coalesce(s.volume, 1) = 1
                 ORDER BY s.id, ed.id
                """).getResultList();
        List<Map<String, Object>> itens = registros.stream().map(linha -> {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("serieId", linha[0]);
            item.put("titulo", linha[1]);
            item.put("volume", linha[2]);
            item.put("descricao", linha[3]);
            item.put("editora", linha[4]);
            item.put("edicaoId", linha[5]);
            item.put("numero", linha[6]);
            item.put("urlCapa", linha[7]);
            return item;
        }).toList();
        Object migracao = entityManager.createNativeQuery("""
                SELECT version
                  FROM flyway_schema_history
                 WHERE success = TRUE
                 ORDER BY installed_rank DESC
                 LIMIT 1
                """).getSingleResult();
        return Map.of("migracao", migracao, "registros", itens);
    }

    public record VersaoResposta(String versao, LocalDateTime dataHora) {
    }

}
