package br.com.hqhub.resource;

import java.net.URI;
import br.com.hqhub.dto.AtualizacaoSerieDTO;
import br.com.hqhub.dto.CadastroSerieDTO;
import br.com.hqhub.dto.PaginaRespostaDTO;
import br.com.hqhub.dto.SerieRespostaDTO;
import br.com.hqhub.service.SerieService;
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

@Path("/series")
@Authenticated
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class SerieResource {

    private final SerieService serieService;

    public SerieResource(SerieService serieService) {
        this.serieService = serieService;
    }

    @POST
    public Response cadastrar(@Valid CadastroSerieDTO dto) {
        SerieRespostaDTO serie = serieService.cadastrar(dto);
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
            @QueryParam("pagina") Integer pagina,
            @QueryParam("tamanho") Integer tamanho) {
        PaginaRespostaDTO<SerieRespostaDTO> series = serieService.listarPaginado(
                busca,
                pagina == null ? 0 : pagina,
                tamanho == null ? 20 : tamanho);
        return Response.ok(series).build();
    }

    @PUT
    @Path("/{id}")
    public Response atualizar(@PathParam("id") Long id, @Valid AtualizacaoSerieDTO dto) {
        SerieRespostaDTO serie = serieService.atualizar(id, dto);
        return Response.ok(serie).build();
    }

    @DELETE
    @Path("/{id}")
    public Response remover(@PathParam("id") Long id) {
        serieService.remover(id);
        return Response.noContent().build();
    }
}
