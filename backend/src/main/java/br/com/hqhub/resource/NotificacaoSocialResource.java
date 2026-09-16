package br.com.hqhub.resource;

import br.com.hqhub.service.NotificacaoSocialService;
import io.quarkus.security.Authenticated;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/notificacoes-sociais")
@Authenticated
@Produces(MediaType.APPLICATION_JSON)
public class NotificacaoSocialResource {
    private final NotificacaoSocialService service;
    public NotificacaoSocialResource(NotificacaoSocialService service) { this.service = service; }
    @GET public Response listar() { return Response.ok(service.listar()).build(); }
    @GET @Path("/nao-lidas") public Response contar() { return Response.ok(java.util.Map.of("total", service.contarNaoLidas())).build(); }
    @POST @Path("/marcar-lidas") public Response marcarLidas() { service.marcarTodasComoLidas(); return Response.noContent().build(); }
    @POST @Path("/{id}/marcar-lida") public Response marcarLida(@PathParam("id") Long id) { service.marcarComoLida(id); return Response.noContent().build(); }
}
