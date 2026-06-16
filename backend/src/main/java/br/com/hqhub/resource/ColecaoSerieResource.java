package br.com.hqhub.resource;

import java.net.URI;
import java.util.List;

import br.com.hqhub.dto.AtualizacaoColecaoSerieDTO;
import br.com.hqhub.dto.CadastroColecaoSerieDTO;
import br.com.hqhub.dto.ColecaoSerieRespostaDTO;
import br.com.hqhub.service.ColecaoSerieService;
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

@Path("/colecao/series")
@Authenticated
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class ColecaoSerieResource {

    private final ColecaoSerieService colecaoSerieService;

    public ColecaoSerieResource(ColecaoSerieService colecaoSerieService) {
        this.colecaoSerieService = colecaoSerieService;
    }

    @POST
    public Response cadastrar(@Valid CadastroColecaoSerieDTO dto) {
        ColecaoSerieRespostaDTO resposta = colecaoSerieService.cadastrar(dto);
        return Response.created(URI.create("/colecao/series/" + resposta.id()))
                .entity(resposta)
                .build();
    }

    @GET
    @Path("/{id}")
    public Response buscarPorId(@PathParam("id") Long id) {
        return Response.ok(colecaoSerieService.buscarPorId(id)).build();
    }

    @GET
    public Response listarTodos() {
        List<ColecaoSerieRespostaDTO> series = colecaoSerieService.listarTodos();
        return Response.ok(series).build();
    }

    @PUT
    @Path("/{id}")
    public Response atualizar(@PathParam("id") Long id, @Valid AtualizacaoColecaoSerieDTO dto) {
        return Response.ok(colecaoSerieService.atualizar(id, dto)).build();
    }

    @DELETE
    @Path("/{id}")
    public Response remover(@PathParam("id") Long id) {
        colecaoSerieService.remover(id);
        return Response.noContent().build();
    }
}
