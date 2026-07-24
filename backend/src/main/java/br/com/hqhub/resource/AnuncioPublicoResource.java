package br.com.hqhub.resource;

import br.com.hqhub.service.AnuncioService;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/publico/anuncios")
@Produces(MediaType.APPLICATION_JSON)
public class AnuncioPublicoResource {

    private final AnuncioService anuncioService;

    public AnuncioPublicoResource(AnuncioService anuncioService) {
        this.anuncioService = anuncioService;
    }

    @GET
    public Response listarAtivos() {
        return Response.ok(anuncioService.listarAtivosPublicos()).build();
    }
}
