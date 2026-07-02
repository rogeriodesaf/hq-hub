package br.com.hqhub.resource;

import java.net.URI;
import br.com.hqhub.dto.AtualizacaoSerieDTO;
import br.com.hqhub.dto.CadastroSerieComEdicoesDTO;
import br.com.hqhub.dto.CadastroSerieDTO;
import br.com.hqhub.dto.PaginaRespostaDTO;
import br.com.hqhub.dto.SerieRespostaDTO;
import br.com.hqhub.service.DeduplicacaoSerieService;
import br.com.hqhub.service.SerieService;
import io.quarkus.security.Authenticated;
import jakarta.annotation.security.RolesAllowed;
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

@Path("/series")
@Authenticated
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class SerieResource {

    private final SerieService serieService;
    private final DeduplicacaoSerieService deduplicacaoSerieService;

    public SerieResource(SerieService serieService, DeduplicacaoSerieService deduplicacaoSerieService) {
        this.serieService = serieService;
        this.deduplicacaoSerieService = deduplicacaoSerieService;
    }

    @POST
    public Response cadastrar(@Valid CadastroSerieDTO dto) {
        SerieRespostaDTO serie = serieService.cadastrar(dto);
        return Response.created(URI.create("/series/" + serie.id()))
                .entity(serie)
                .build();
    }

    @POST
    @Path("/com-edicoes")
    public Response cadastrarComEdicoes(@Valid CadastroSerieComEdicoesDTO dto) {
        SerieRespostaDTO serie = serieService.cadastrarComEdicoes(dto);
        return Response.created(URI.create("/series/" + serie.id()))
                .entity(serie)
                .build();
    }

    @GET
    @Path("/{id}")
    public Response buscarPorId(@PathParam("id") Long id) {
        SerieRespostaDTO serie = serieService.buscarPorId(id);
        return Response.ok(serie).build();
    }

    @GET
    public Response listarTodos(
            @QueryParam("busca") String busca,
            @QueryParam("inicial") String inicial,
            @QueryParam("pagina") Integer pagina,
            @QueryParam("tamanho") Integer tamanho) {
        PaginaRespostaDTO<SerieRespostaDTO> series = serieService.listarPaginado(
                busca,
                inicial,
                pagina == null ? 0 : pagina,
                tamanho == null ? 20 : tamanho);
        return Response.ok(series).build();
    }

    @GET
    @Path("/duplicidades")
    @RolesAllowed({ "COLABORADOR", "ADMINISTRADOR" })
    public Response listarDuplicidades() {
        return Response.ok(deduplicacaoSerieService.listarDuplicidades()).build();
    }

    @POST
    @Path("/deduplicar")
    @RolesAllowed("ADMINISTRADOR")
    public Response deduplicar() {
        return Response.ok(deduplicacaoSerieService.deduplicar()).build();
    }

    @PUT
    @Path("/{id}")
    @RolesAllowed({ "COLABORADOR", "ADMINISTRADOR" })
    public Response atualizar(@PathParam("id") Long id, @Valid AtualizacaoSerieDTO dto) {
        SerieRespostaDTO serie = serieService.atualizar(id, dto);
        return Response.ok(serie).build();
    }

    @DELETE
    @Path("/{id}")
    @RolesAllowed("ADMINISTRADOR")
    public Response remover(@PathParam("id") Long id) {
        serieService.remover(id);
        return Response.noContent().build();
    }
}

