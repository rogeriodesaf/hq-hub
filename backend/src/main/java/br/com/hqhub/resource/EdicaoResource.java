package br.com.hqhub.resource;

import java.net.URI;
import br.com.hqhub.dto.AtualizacaoCapaEdicaoDTO;
import br.com.hqhub.dto.AtualizacaoEdicaoDTO;
import br.com.hqhub.dto.CadastroEdicaoDTO;
import br.com.hqhub.dto.EdicaoRespostaDTO;
import br.com.hqhub.dto.PaginaRespostaDTO;
import br.com.hqhub.entity.TipoAnuncio;
import br.com.hqhub.service.AnuncioService;
import br.com.hqhub.service.DeduplicacaoEdicaoService;
import br.com.hqhub.service.EdicaoService;
import io.quarkus.security.Authenticated;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.PATCH;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/edicoes")
@Authenticated
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class EdicaoResource {

    private final EdicaoService edicaoService;
    private final AnuncioService anuncioService;
    private final DeduplicacaoEdicaoService deduplicacaoEdicaoService;

    public EdicaoResource(
            EdicaoService edicaoService,
            AnuncioService anuncioService,
            DeduplicacaoEdicaoService deduplicacaoEdicaoService) {
        this.edicaoService = edicaoService;
        this.anuncioService = anuncioService;
        this.deduplicacaoEdicaoService = deduplicacaoEdicaoService;
    }

    @POST
    public Response cadastrar(@Valid CadastroEdicaoDTO dto) {
        EdicaoRespostaDTO edicao = edicaoService.cadastrar(dto);
        return Response.created(URI.create("/edicoes/" + edicao.id()))
                .entity(edicao)
                .build();
    }

    @GET
    @Path("/{id}")
    public Response buscarPorId(@PathParam("id") Long id) {
        EdicaoRespostaDTO edicao = edicaoService.buscarPorId(id);
        return Response.ok(edicao).build();
    }

    @GET
    @Path("/{id}/anuncios")
    public Response listarAnunciosPorEdicao(@PathParam("id") Long id, @QueryParam("tipo") TipoAnuncio tipo) {
        return Response.ok(anuncioService.listarAtivosPorEdicao(id, tipo)).build();
    }

    @GET
    public Response listarTodos(
            @QueryParam("serieId") Long serieId,
            @QueryParam("busca") String busca,
            @QueryParam("pagina") Integer pagina,
            @QueryParam("tamanho") Integer tamanho) {
        PaginaRespostaDTO<EdicaoRespostaDTO> edicoes = edicaoService.listarPaginado(
                serieId,
                busca,
                pagina == null ? 0 : pagina,
                tamanho == null ? 50 : tamanho);
        return Response.ok(edicoes).build();
    }

    @GET
    @Path("/duplicidades")
    public Response listarDuplicidades() {
        return Response.ok(deduplicacaoEdicaoService.listarDuplicidades()).build();
    }

    @POST
    @Path("/deduplicar")
    public Response deduplicar() {
        return Response.ok(deduplicacaoEdicaoService.deduplicar()).build();
    }

    @PUT
    @Path("/{id}")
    public Response atualizar(@PathParam("id") Long id, @Valid AtualizacaoEdicaoDTO dto) {
        EdicaoRespostaDTO edicao = edicaoService.atualizar(id, dto);
        return Response.ok(edicao).build();
    }

    @PATCH
    @Path("/{id}/capa")
    public Response atualizarCapa(@PathParam("id") Long id, @Valid AtualizacaoCapaEdicaoDTO dto) {
        EdicaoRespostaDTO edicao = edicaoService.atualizarCapa(id, dto);
        return Response.ok(edicao).build();
    }

    @DELETE
    @Path("/{id}")
    public Response remover(@PathParam("id") Long id) {
        edicaoService.remover(id);
        return Response.noContent().build();
    }
}
