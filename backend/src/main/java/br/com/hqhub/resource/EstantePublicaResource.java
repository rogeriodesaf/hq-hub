package br.com.hqhub.resource;

import br.com.hqhub.service.EstanteService;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/publico/estantes")
@Produces(MediaType.APPLICATION_JSON)
public class EstantePublicaResource {

    private final EstanteService estanteService;

    public EstantePublicaResource(EstanteService estanteService) {
        this.estanteService = estanteService;
    }

    @GET
    @Path("/{usuarioId}")
    public Response obter(@PathParam("usuarioId") Long usuarioId) {
        return Response.ok(estanteService.montarEstanteCompartilhada(usuarioId)).build();
    }
}
