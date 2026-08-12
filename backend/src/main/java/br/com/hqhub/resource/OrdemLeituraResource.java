package br.com.hqhub.resource;

import br.com.hqhub.dto.AtualizacaoProgressoLeituraDTO;
import br.com.hqhub.service.OrdemLeituraService;
import io.quarkus.security.Authenticated;
import jakarta.validation.Valid;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/ordens-leitura")
@Authenticated
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class OrdemLeituraResource {
    private final OrdemLeituraService service;
    public OrdemLeituraResource(OrdemLeituraService service) { this.service = service; }
    @GET public Response listar() { return Response.ok(service.listar()).build(); }
    @GET @Path("/{slug}") public Response buscar(@PathParam("slug") String slug) {
        return Response.ok(service.buscar(slug)).build();
    }
    @PUT @Path("/itens/{id}/progresso") public Response progresso(@PathParam("id") Long id,
            @Valid AtualizacaoProgressoLeituraDTO dto) {
        return Response.ok(service.atualizarProgresso(id, dto.lido())).build();
    }
}
