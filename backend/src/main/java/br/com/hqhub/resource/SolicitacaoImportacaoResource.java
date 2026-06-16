package br.com.hqhub.resource;

import java.net.URI;
import java.util.List;

import br.com.hqhub.dto.CadastroSolicitacaoImportacaoDTO;
import br.com.hqhub.dto.SolicitacaoImportacaoRespostaDTO;
import br.com.hqhub.service.SolicitacaoImportacaoService;
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

@Path("/importacoes")
@Authenticated
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class SolicitacaoImportacaoResource {

    private final SolicitacaoImportacaoService solicitacaoImportacaoService;

    public SolicitacaoImportacaoResource(SolicitacaoImportacaoService solicitacaoImportacaoService) {
        this.solicitacaoImportacaoService = solicitacaoImportacaoService;
    }

    @POST
    public Response cadastrar(@Valid CadastroSolicitacaoImportacaoDTO dto) {
        SolicitacaoImportacaoRespostaDTO resposta = solicitacaoImportacaoService.cadastrar(dto);
        return Response.accepted(URI.create("/importacoes/" + resposta.id()))
                .entity(resposta)
                .build();
    }

    @GET
    public Response listarTodos() {
        List<SolicitacaoImportacaoRespostaDTO> importacoes = solicitacaoImportacaoService.listarTodos();
        return Response.ok(importacoes).build();
    }

    @GET
    @Path("/{id}")
    public Response buscarPorId(@PathParam("id") Long id) {
        return Response.ok(solicitacaoImportacaoService.buscarPorId(id)).build();
    }

    @POST
    @Path("/{id}/processar")
    public Response processar(@PathParam("id") Long id) {
        return Response.ok(solicitacaoImportacaoService.processar(id)).build();
    }
}
