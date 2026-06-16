package br.com.hqhub.resource;

import java.util.List;

import br.com.hqhub.dto.EdicaoRespostaDTO;
import br.com.hqhub.service.FaltanteService;
import io.quarkus.security.Authenticated;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/colecao/faltantes")
@Authenticated
@Produces(MediaType.APPLICATION_JSON)
public class FaltanteResource {

    private final FaltanteService faltanteService;

    public FaltanteResource(FaltanteService faltanteService) {
        this.faltanteService = faltanteService;
    }

    @GET
    @Path("/series/{serieId}")
    public Response listarFaltantesPorSerie(@PathParam("serieId") Long serieId) {
        List<EdicaoRespostaDTO> edicoes = faltanteService.listarFaltantesPorSerie(serieId);
        return Response.ok(edicoes).build();
    }
}
