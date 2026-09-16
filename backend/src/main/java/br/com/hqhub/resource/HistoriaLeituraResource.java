package br.com.hqhub.resource;

import br.com.hqhub.dto.CadastroHistoriaLeituraDTO;
import br.com.hqhub.service.HistoriaLeituraService;
import io.quarkus.security.Authenticated;
import jakarta.validation.Valid;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/historias-leitura")
@Authenticated
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class HistoriaLeituraResource {
    private final HistoriaLeituraService service;

    public HistoriaLeituraResource(HistoriaLeituraService service) {
        this.service = service;
    }

    @GET
    public Response listar() {
        return Response.ok(service.listar()).build();
    }

    @POST
    public Response criar(@Valid CadastroHistoriaLeituraDTO dto) {
        return Response.status(Response.Status.CREATED).entity(service.criar(dto)).build();
    }

    @POST
    @Path("/{id}/visualizacoes")
    public Response visualizar(@PathParam("id") Long id) {
        return Response.ok(service.visualizar(id)).build();
    }

    @GET
    @Path("/{id}/visualizacoes")
    public Response listarVisualizacoes(@PathParam("id") Long id) {
        return Response.ok(service.listarVisualizacoes(id)).build();
    }

    @DELETE
    @Path("/{id}")
    public Response remover(@PathParam("id") Long id) {
        service.remover(id);
        return Response.noContent().build();
    }
}
