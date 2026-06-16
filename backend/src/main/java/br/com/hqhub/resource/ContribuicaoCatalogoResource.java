package br.com.hqhub.resource;

import java.net.URI;

import br.com.hqhub.dto.CadastroContribuicaoCatalogoDTO;
import br.com.hqhub.dto.ContribuicaoCatalogoRespostaDTO;
import br.com.hqhub.dto.RevisaoContribuicaoCatalogoDTO;
import br.com.hqhub.service.ContribuicaoCatalogoService;
import io.quarkus.security.Authenticated;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/contribuicoes-catalogo")
@Authenticated
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class ContribuicaoCatalogoResource {

    private final ContribuicaoCatalogoService contribuicaoCatalogoService;

    public ContribuicaoCatalogoResource(ContribuicaoCatalogoService contribuicaoCatalogoService) {
        this.contribuicaoCatalogoService = contribuicaoCatalogoService;
    }

    @POST
    public Response cadastrar(@Valid CadastroContribuicaoCatalogoDTO dto) {
        ContribuicaoCatalogoRespostaDTO resposta = contribuicaoCatalogoService.cadastrar(dto);
        return Response.created(URI.create("/contribuicoes-catalogo/" + resposta.id()))
                .entity(resposta)
                .build();
    }

    @GET
    @Path("/minhas")
    public Response listarMinhas() {
        return Response.ok(contribuicaoCatalogoService.listarMinhas()).build();
    }

    @GET
    @Path("/pendentes")
    public Response listarPendentes() {
        return Response.ok(contribuicaoCatalogoService.listarPendentes()).build();
    }

    @POST
    @Path("/{id}/aprovar")
    public Response aprovar(@PathParam("id") Long id, @Valid RevisaoContribuicaoCatalogoDTO dto) {
        return Response.ok(contribuicaoCatalogoService.aprovar(id, dto)).build();
    }

    @POST
    @Path("/{id}/recusar")
    public Response recusar(@PathParam("id") Long id, @Valid RevisaoContribuicaoCatalogoDTO dto) {
        return Response.ok(contribuicaoCatalogoService.recusar(id, dto)).build();
    }
}
