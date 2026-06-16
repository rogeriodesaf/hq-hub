package br.com.hqhub.resource;

import br.com.hqhub.service.PesquisaCatalogoService;
import io.quarkus.security.Authenticated;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/catalogo")
@Authenticated
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class CatalogoResource {

    private final PesquisaCatalogoService pesquisaCatalogoService;

    public CatalogoResource(PesquisaCatalogoService pesquisaCatalogoService) {
        this.pesquisaCatalogoService = pesquisaCatalogoService;
    }

    @GET
    @Path("/pesquisa")
    public Response pesquisar(@QueryParam("termo") String termo) {
        return Response.ok(pesquisaCatalogoService.pesquisarCatalogo(termo)).build();
    }
}
