package br.com.hqhub.resource;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

import java.time.LocalDateTime;
import java.util.List;
import jakarta.persistence.EntityManager;

@Path("/diagnostico")
@Produces(MediaType.APPLICATION_JSON)
public class DiagnosticoResource {

    private static final String VERSAO_BACKEND = "feed-premium-2026-08-05";
    private final EntityManager entityManager;

    public DiagnosticoResource(EntityManager entityManager) {
        this.entityManager = entityManager;
    }

    @GET
    @Path("/versao")
    public VersaoResposta versao() {
        return new VersaoResposta(VERSAO_BACKEND, LocalDateTime.now());
    }

    @GET
    @Path("/auditoria-serie-974")
    public List<EdicaoAuditoria> auditarSerie974() {
        @SuppressWarnings("unchecked")
        List<Object[]> linhas = entityManager.createNativeQuery("""
                select e.id, e.numero, e.titulo, e.nome_volume, e.url_capa, s.id,
                    s.titulo, s.volume, editora.nome
                from edicoes e
                join series s on s.id = e.serie_id
                join editoras editora on editora.id = s.editora_id
                where s.id = 974
                order by e.id
                """).getResultList();
        return linhas.stream()
                .map(linha -> new EdicaoAuditoria(
                        ((Number) linha[0]).longValue(), (String) linha[1], (String) linha[2], (String) linha[3],
                        (String) linha[4], ((Number) linha[5]).longValue(), (String) linha[6],
                        linha[7] == null ? null : ((Number) linha[7]).intValue(),
                        (String) linha[8]))
                .toList();
    }

    public record VersaoResposta(String versao, LocalDateTime dataHora) {
    }

    public record EdicaoAuditoria(Long id, String numero, String titulo, String nomeVolume,
            String urlCapa, Long serieId, String serieTitulo, Integer serieVolume, String editora) {
    }
}
