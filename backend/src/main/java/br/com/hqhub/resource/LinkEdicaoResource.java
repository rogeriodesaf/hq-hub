package br.com.hqhub.resource;

import java.net.URI;
import java.util.List;

import br.com.hqhub.dto.AtualizacaoLinkEdicaoDTO;
import br.com.hqhub.dto.CadastroLinkEdicaoDTO;
import br.com.hqhub.dto.LinkEdicaoRespostaDTO;
import br.com.hqhub.service.LinkEdicaoService;
import io.quarkus.security.Authenticated;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/links-edicoes")
@Authenticated
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class LinkEdicaoResource {

    private final LinkEdicaoService linkEdicaoService;

    public LinkEdicaoResource(LinkEdicaoService linkEdicaoService) {
        this.linkEdicaoService = linkEdicaoService;
    }

    @POST
    public Response cadastrar(@Valid CadastroLinkEdicaoDTO dto) {
        LinkEdicaoRespostaDTO resposta = linkEdicaoService.cadastrar(dto);
        return Response.created(URI.create("/links-edicoes/" + resposta.id()))
                .entity(resposta)
                .build();
    }

    @GET
    @Path("/{id}")
    public Response buscarPorId(@PathParam("id") Long id) {
        return Response.ok(linkEdicaoService.buscarPorId(id)).build();
    }

    @GET
    @Path("/edicoes/{edicaoId}")
    public Response listarPorEdicao(@PathParam("edicaoId") Long edicaoId) {
        List<LinkEdicaoRespostaDTO> links = linkEdicaoService.listarPorEdicao(edicaoId);
        return Response.ok(links).build();
    }

    @PUT
    @Path("/{id}")
    public Response atualizar(@PathParam("id") Long id, @Valid AtualizacaoLinkEdicaoDTO dto) {
        return Response.ok(linkEdicaoService.atualizar(id, dto)).build();
    }

    @DELETE
    @Path("/{id}")
    public Response remover(@PathParam("id") Long id) {
        linkEdicaoService.remover(id);
        return Response.noContent().build();
    }
}
