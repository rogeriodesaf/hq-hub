package br.com.hqhub.resource;

import java.net.URI;
import java.util.List;

import br.com.hqhub.dto.CadastroRelacionamentoSerieDTO;
import br.com.hqhub.dto.RelacionamentoSerieRespostaDTO;
import br.com.hqhub.service.RelacionamentoSerieService;
import io.quarkus.security.Authenticated;
import jakarta.annotation.security.RolesAllowed;
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

@Path("/relacionamentos-series")
@Authenticated
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class RelacionamentoSerieResource {

    private final RelacionamentoSerieService relacionamentoSerieService;

    public RelacionamentoSerieResource(RelacionamentoSerieService relacionamentoSerieService) {
        this.relacionamentoSerieService = relacionamentoSerieService;
    }

    @POST
    @RolesAllowed({ "COLABORADOR", "ADMINISTRADOR" })
    public Response cadastrar(@Valid CadastroRelacionamentoSerieDTO dto) {
        RelacionamentoSerieRespostaDTO relacionamento = relacionamentoSerieService.cadastrar(dto);
        return Response.created(URI.create("/relacionamentos-series/" + relacionamento.id()))
                .entity(relacionamento)
                .build();
    }

    @GET
    @Path("/series/{serieId}")
    public Response listarPorSerie(@PathParam("serieId") Long serieId) {
        List<RelacionamentoSerieRespostaDTO> relacionamentos = relacionamentoSerieService.listarPorSerie(serieId);
        return Response.ok(relacionamentos).build();
    }

    @DELETE
    @Path("/{id}")
    @RolesAllowed("ADMINISTRADOR")
    public Response remover(@PathParam("id") Long id) {
        relacionamentoSerieService.remover(id);
        return Response.noContent().build();
    }
}
