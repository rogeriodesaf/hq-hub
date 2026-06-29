package br.com.hqhub.resource;

import br.com.hqhub.dto.CadastroComentarioColecaoDTO;
import br.com.hqhub.service.ColecaoSocialService;
import io.quarkus.security.Authenticated;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/colecao/social")
@Authenticated
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class ColecaoSocialResource {

    private final ColecaoSocialService colecaoSocialService;

    public ColecaoSocialResource(ColecaoSocialService colecaoSocialService) {
        this.colecaoSocialService = colecaoSocialService;
    }

    @GET
    @Path("/usuarios/{usuarioId}")
    public Response obterInteracoes(@PathParam("usuarioId") Long usuarioId, @QueryParam("itens") String itens) {
        return Response.ok(colecaoSocialService.obterInteracoes(usuarioId, itens)).build();
    }

    @POST
    @Path("/usuarios/{usuarioId}/curtidas")
    public Response alternarCurtidaColecao(@PathParam("usuarioId") Long usuarioId) {
        return Response.ok(colecaoSocialService.alternarCurtidaColecao(usuarioId)).build();
    }

    @POST
    @Path("/usuarios/{usuarioId}/comentarios")
    public Response comentarColecao(@PathParam("usuarioId") Long usuarioId, @Valid CadastroComentarioColecaoDTO dto) {
        return Response.ok(colecaoSocialService.comentarColecao(usuarioId, dto)).build();
    }

    @DELETE
    @Path("/usuarios/{usuarioId}/comentarios/{comentarioId}")
    public Response removerComentarioColecao(@PathParam("usuarioId") Long usuarioId, @PathParam("comentarioId") Long comentarioId) {
        return Response.ok(colecaoSocialService.removerComentarioColecao(usuarioId, comentarioId)).build();
    }

    @POST
    @Path("/itens/{itemColecaoId}/curtidas")
    public Response alternarCurtidaItem(@PathParam("itemColecaoId") Long itemColecaoId) {
        return Response.ok(colecaoSocialService.alternarCurtidaItem(itemColecaoId)).build();
    }

    @POST
    @Path("/itens/{itemColecaoId}/comentarios")
    public Response comentarItem(@PathParam("itemColecaoId") Long itemColecaoId, @Valid CadastroComentarioColecaoDTO dto) {
        return Response.ok(colecaoSocialService.comentarItem(itemColecaoId, dto)).build();
    }

    @DELETE
    @Path("/itens/{itemColecaoId}/comentarios/{comentarioId}")
    public Response removerComentarioItem(@PathParam("itemColecaoId") Long itemColecaoId, @PathParam("comentarioId") Long comentarioId) {
        return Response.ok(colecaoSocialService.removerComentarioItem(itemColecaoId, comentarioId)).build();
    }
}
