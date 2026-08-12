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
        return entityManager.createQuery("""
                select e.id, e.numero, e.titulo, e.nomeVolume, e.urlCapa, e.serie.id,
                    e.serie.titulo, e.serie.volume, e.serie.editora.nome
                from Edicao e
                where e.serie.id = 974
                order by e.id
                """, Object[].class).getResultList().stream()
                .map(linha -> new EdicaoAuditoria(
                        (Long) linha[0], (String) linha[1], (String) linha[2], (String) linha[3],
                        (String) linha[4], (Long) linha[5], (String) linha[6], (Integer) linha[7],
                        (String) linha[8]))
                .toList();
    }

    public record VersaoResposta(String versao, LocalDateTime dataHora) {
    }

    public record EdicaoAuditoria(Long id, String numero, String titulo, String nomeVolume,
            String urlCapa, Long serieId, String serieTitulo, Integer serieVolume, String editora) {
    }
}
