package br.com.hqhub.resource;

import java.util.List;

import br.com.hqhub.dto.EstanteEditoraDTO;
import br.com.hqhub.service.EstanteService;
import io.quarkus.security.Authenticated;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/estante")
@Authenticated
@Produces(MediaType.APPLICATION_JSON)
public class EstanteResource {

    private final EstanteService estanteService;

    public EstanteResource(EstanteService estanteService) {
        this.estanteService = estanteService;
    }

    @GET
    public Response montarEstante() {
        List<EstanteEditoraDTO> estante = estanteService.montarEstante();
        return Response.ok(estante).build();
    }
}
