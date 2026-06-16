package br.com.hqhub.resource;

import java.net.URI;
import java.util.List;

import br.com.hqhub.dto.CadastroPublicacaoRelacionadaDTO;
import br.com.hqhub.dto.PublicacaoRelacionadaRespostaDTO;
import br.com.hqhub.service.PublicacaoRelacionadaService;
import io.quarkus.security.Authenticated;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/publicacoes-relacionadas")
@Authenticated
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class PublicacaoRelacionadaResource {

    private final PublicacaoRelacionadaService publicacaoRelacionadaService;

    public PublicacaoRelacionadaResource(PublicacaoRelacionadaService publicacaoRelacionadaService) {
        this.publicacaoRelacionadaService = publicacaoRelacionadaService;
    }

    @POST
    public Response cadastrar(@Valid CadastroPublicacaoRelacionadaDTO dto) {
        PublicacaoRelacionadaRespostaDTO resposta = publicacaoRelacionadaService.cadastrar(dto);
        return Response.created(URI.create("/publicacoes-relacionadas/" + resposta.id()))
                .entity(resposta)
                .build();
    }

    @GET
    @Path("/edicoes/{edicaoId}")
    public Response listarPorEdicao(@PathParam("edicaoId") Long edicaoId) {
        List<PublicacaoRelacionadaRespostaDTO> publicacoes = publicacaoRelacionadaService.listarPorEdicao(edicaoId);
        return Response.ok(publicacoes).build();
    }

    @GET
    @Path("/fontes/{fonteExterna}/itens/{idExterno}")
    public Response listarPorOrigemExterna(
            @PathParam("fonteExterna") String fonteExterna,
            @PathParam("idExterno") String idExterno) {
        List<PublicacaoRelacionadaRespostaDTO> publicacoes = publicacaoRelacionadaService
                .listarPorOrigemExterna(fonteExterna, idExterno);
        return Response.ok(publicacoes).build();
    }

    @DELETE
    @Path("/{id}")
    public Response remover(@PathParam("id") Long id) {
        publicacaoRelacionadaService.remover(id);
        return Response.noContent().build();
    }
}
