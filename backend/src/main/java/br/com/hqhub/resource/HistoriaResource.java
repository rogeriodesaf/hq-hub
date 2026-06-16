package br.com.hqhub.resource;

import java.net.URI;

import br.com.hqhub.dto.AtualizacaoHistoriaDTO;
import br.com.hqhub.dto.CadastroConteudoEdicaoDTO;
import br.com.hqhub.dto.CadastroHistoriaDTO;
import br.com.hqhub.dto.CadastroPublicacaoHistoriaDTO;
import br.com.hqhub.dto.ConteudoEdicaoRespostaDTO;
import br.com.hqhub.dto.HistoriaRespostaDTO;
import br.com.hqhub.dto.PublicacaoHistoriaRespostaDTO;
import br.com.hqhub.dto.SugestaoPublicacaoHistoriaDTO;
import br.com.hqhub.service.HistoriaService;
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
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/")
@Authenticated
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class HistoriaResource {

    private final HistoriaService historiaService;

    public HistoriaResource(HistoriaService historiaService) {
        this.historiaService = historiaService;
    }

    @POST
    @Path("/historias")
    public Response cadastrarHistoria(@Valid CadastroHistoriaDTO dto) {
        HistoriaRespostaDTO resposta = historiaService.cadastrarHistoria(dto);
        return Response.created(URI.create("/historias/" + resposta.id()))
                .entity(resposta)
                .build();
    }

    @GET
    @Path("/historias")
    public Response listarHistorias() {
        return Response.ok(historiaService.listarHistorias()).build();
    }

    @GET
    @Path("/historias/{id}")
    public Response buscarHistoriaPorId(@PathParam("id") Long id) {
        return Response.ok(historiaService.buscarHistoriaPorIdResposta(id)).build();
    }

    @PUT
    @Path("/historias/{id}")
    public Response atualizarHistoria(@PathParam("id") Long id, @Valid AtualizacaoHistoriaDTO dto) {
        return Response.ok(historiaService.atualizarHistoria(id, dto)).build();
    }

    @POST
    @Path("/conteudos-edicoes")
    public Response adicionarConteudo(@Valid CadastroConteudoEdicaoDTO dto) {
        ConteudoEdicaoRespostaDTO resposta = historiaService.adicionarConteudo(dto);
        return Response.created(URI.create("/conteudos-edicoes/" + resposta.id()))
                .entity(resposta)
                .build();
    }

    @GET
    @Path("/conteudos-edicoes/edicoes/{edicaoId}")
    public Response listarConteudosPorEdicao(@PathParam("edicaoId") Long edicaoId) {
        return Response.ok(historiaService.listarConteudosPorEdicao(edicaoId)).build();
    }

    @DELETE
    @Path("/conteudos-edicoes/{id}")
    public Response removerConteudo(@PathParam("id") Long id) {
        historiaService.removerConteudo(id);
        return Response.noContent().build();
    }

    @POST
    @Path("/publicacoes-historias")
    public Response cadastrarPublicacao(@Valid CadastroPublicacaoHistoriaDTO dto) {
        PublicacaoHistoriaRespostaDTO resposta = historiaService.cadastrarPublicacao(dto);
        return Response.created(URI.create("/publicacoes-historias/" + resposta.id()))
                .entity(resposta)
                .build();
    }

    @POST
    @Path("/historias/{idHistoria}/publicacoes")
    public Response sugerirPublicacao(
            @PathParam("idHistoria") Long idHistoria,
            @Valid SugestaoPublicacaoHistoriaDTO dto) {
        PublicacaoHistoriaRespostaDTO resposta = historiaService.sugerirPublicacao(idHistoria, dto);
        return Response.created(URI.create("/historias/" + idHistoria + "/publicacoes/" + resposta.id()))
                .entity(resposta)
                .build();
    }

    @GET
    @Path("/publicacoes-historias/historias/{historiaId}")
    public Response listarPublicacoesPorHistoria(@PathParam("historiaId") Long historiaId) {
        return Response.ok(historiaService.listarPublicacoesPorHistoria(historiaId)).build();
    }

    @DELETE
    @Path("/publicacoes-historias/{id}")
    public Response removerPublicacao(@PathParam("id") Long id) {
        historiaService.removerPublicacao(id);
        return Response.noContent().build();
    }

    @GET
    @Path("/cruzamentos-edicoes")
    public Response cruzarEdicoes(
            @QueryParam("edicaoOriginalId") Long edicaoOriginalId,
            @QueryParam("edicaoComparadaId") Long edicaoComparadaId) {
        return Response.ok(historiaService.cruzarEdicoes(edicaoOriginalId, edicaoComparadaId)).build();
    }
}
