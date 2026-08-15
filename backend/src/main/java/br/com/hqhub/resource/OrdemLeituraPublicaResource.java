package br.com.hqhub.resource;

import br.com.hqhub.service.OrdemLeituraService;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/publico/ordens-leitura")
@Produces(MediaType.APPLICATION_JSON)
public class OrdemLeituraPublicaResource {
    private final OrdemLeituraService service;

    public OrdemLeituraPublicaResource(OrdemLeituraService service) {
        this.service = service;
    }

    @GET
    @Path("/{slug}")
    public Response buscar(@PathParam("slug") String slug) {
        return Response.ok(service.buscarPublica(slug)).build();
    }
}
