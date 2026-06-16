package br.com.hqhub.resource;

import br.com.hqhub.service.IntegracaoExternaService;
import io.quarkus.security.Authenticated;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/integracoes-externas")
@Authenticated
@Produces(MediaType.APPLICATION_JSON)
public class IntegracaoExternaResource {

    private final IntegracaoExternaService integracaoExternaService;

    public IntegracaoExternaResource(IntegracaoExternaService integracaoExternaService) {
        this.integracaoExternaService = integracaoExternaService;
    }

    @GET
    @Path("/fontes")
    public Response listarFontes() {
        return Response.ok(integracaoExternaService.listarFontes()).build();
    }

    @GET
    @Path("/{fonteExterna}/buscar")
    public Response buscar(@PathParam("fonteExterna") String fonteExterna, @QueryParam("termo") String termo) {
        return Response.ok(integracaoExternaService.buscar(fonteExterna, termo)).build();
    }
}
