package br.com.hqhub.resource;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

import java.time.LocalDateTime;

@Path("/diagnostico")
@Produces(MediaType.APPLICATION_JSON)
public class DiagnosticoResource {

    private static final String VERSAO_BACKEND = "estante-serie-completa-2026-08-04";

    @GET
    @Path("/versao")
    public VersaoResposta versao() {
        return new VersaoResposta(VERSAO_BACKEND, LocalDateTime.now());
    }

    public record VersaoResposta(String versao, LocalDateTime dataHora) {
    }
}
