package br.com.hqhub.resource;

import java.net.URI;
import java.util.List;

import br.com.hqhub.dto.AnuncioRespostaDTO;
import br.com.hqhub.dto.AtualizacaoAnuncioDTO;
import br.com.hqhub.dto.CadastroAnuncioDTO;
import br.com.hqhub.dto.CadastroFotoAnuncioDTO;
import br.com.hqhub.dto.FotoAnuncioRespostaDTO;
import br.com.hqhub.entity.TipoAnuncio;
import br.com.hqhub.service.AnuncioService;
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

@Path("/anuncios")
@Authenticated
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class AnuncioResource {

    private final AnuncioService anuncioService;

    public AnuncioResource(AnuncioService anuncioService) {
        this.anuncioService = anuncioService;
    }

    @POST
    public Response cadastrar(@Valid CadastroAnuncioDTO dto) {
        AnuncioRespostaDTO resposta = anuncioService.cadastrar(dto);
        return Response.created(URI.create("/anuncios/" + resposta.id()))
                .entity(resposta)
                .build();
    }

    @GET
    public Response listarAtivos() {
        List<AnuncioRespostaDTO> anuncios = anuncioService.listarAtivos();
        return Response.ok(anuncios).build();
    }

    @GET
    @Path("/meus")
    public Response listarMeusAnuncios() {
        return Response.ok(anuncioService.listarMeusAnuncios()).build();
    }

    @GET
    @Path("/{id}")
    public Response buscarPorId(@PathParam("id") Long id) {
        return Response.ok(anuncioService.buscarPorId(id)).build();
    }

    @GET
    @Path("/edicoes/{edicaoId}")
    public Response listarPorEdicao(@PathParam("edicaoId") Long edicaoId, @QueryParam("tipo") TipoAnuncio tipo) {
        return Response.ok(anuncioService.listarAtivosPorEdicao(edicaoId, tipo)).build();
    }

    @GET
    @Path("/usuarios/{usuarioId}")
    public Response listarPorUsuario(@PathParam("usuarioId") Long usuarioId) {
        return Response.ok(anuncioService.listarAtivosPorUsuario(usuarioId)).build();
    }

    @PUT
    @Path("/{id}")
    public Response atualizar(@PathParam("id") Long id, @Valid AtualizacaoAnuncioDTO dto) {
        return Response.ok(anuncioService.atualizar(id, dto)).build();
    }

    @POST
    @Path("/{id}/pausar")
    public Response pausar(@PathParam("id") Long id) {
        return Response.ok(anuncioService.pausar(id)).build();
    }

    @POST
    @Path("/{id}/reativar")
    public Response reativar(@PathParam("id") Long id) {
        return Response.ok(anuncioService.reativar(id)).build();
    }

    @POST
    @Path("/{id}/encerrar")
    public Response encerrar(@PathParam("id") Long id) {
        return Response.ok(anuncioService.encerrar(id)).build();
    }

    @DELETE
    @Path("/{id}")
    public Response remover(@PathParam("id") Long id) {
        anuncioService.remover(id);
        return Response.noContent().build();
    }

    @POST
    @Path("/{id}/fotos")
    public Response adicionarFoto(@PathParam("id") Long id, @Valid CadastroFotoAnuncioDTO dto) {
        FotoAnuncioRespostaDTO resposta = anuncioService.adicionarFoto(id, dto);
        return Response.created(URI.create("/anuncios/" + id + "/fotos/" + resposta.id()))
                .entity(resposta)
                .build();
    }

    @GET
    @Path("/{id}/fotos")
    public Response listarFotos(@PathParam("id") Long id) {
        return Response.ok(anuncioService.listarFotos(id)).build();
    }

    @DELETE
    @Path("/{id}/fotos/{fotoId}")
    public Response removerFoto(@PathParam("id") Long id, @PathParam("fotoId") Long fotoId) {
        anuncioService.removerFoto(id, fotoId);
        return Response.noContent().build();
    }

    @GET
    @Path("/{id}/contato")
    public Response gerarContato(@PathParam("id") Long id) {
        return Response.ok(anuncioService.gerarContato(id)).build();
    }
}
