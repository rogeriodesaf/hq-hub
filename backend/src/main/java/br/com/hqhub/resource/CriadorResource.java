package br.com.hqhub.resource;

import java.net.URI;
import java.util.List;

import br.com.hqhub.dto.AtualizacaoCriadorDTO;
import br.com.hqhub.dto.CadastroCriadorDTO;
import br.com.hqhub.dto.CadastroCreditoEdicaoDTO;
import br.com.hqhub.dto.CreditoEdicaoRespostaDTO;
import br.com.hqhub.dto.CriadorRespostaDTO;
import br.com.hqhub.entity.PapelCriador;
import br.com.hqhub.service.CreditoEdicaoService;
import br.com.hqhub.service.CriadorService;
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

@Path("/criadores")
@Authenticated
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class CriadorResource {

    private final CriadorService criadorService;
    private final CreditoEdicaoService creditoEdicaoService;

    public CriadorResource(CriadorService criadorService, CreditoEdicaoService creditoEdicaoService) {
        this.criadorService = criadorService;
        this.creditoEdicaoService = creditoEdicaoService;
    }

    @POST
    @RolesAllowed({ "COLABORADOR", "ADMINISTRADOR" })
    public Response cadastrar(@Valid CadastroCriadorDTO dto) {
        CriadorRespostaDTO criador = criadorService.cadastrar(dto);
        return Response.created(URI.create("/criadores/" + criador.id()))
                .entity(criador)
                .build();
    }

    @GET
    public Response listar(@QueryParam("nome") String nome) {
        List<CriadorRespostaDTO> criadores = criadorService.listar(nome);
        return Response.ok(criadores).build();
    }

    @GET
    @Path("/{id}")
    public Response buscarPorId(@PathParam("id") Long id) {
        return Response.ok(criadorService.buscarPorId(id)).build();
    }

    @PUT
    @Path("/{id}")
    @RolesAllowed({ "COLABORADOR", "ADMINISTRADOR" })
    public Response atualizar(@PathParam("id") Long id, @Valid AtualizacaoCriadorDTO dto) {
        return Response.ok(criadorService.atualizar(id, dto)).build();
    }

    @DELETE
    @Path("/{id}")
    @RolesAllowed("ADMINISTRADOR")
    public Response remover(@PathParam("id") Long id) {
        criadorService.remover(id);
        return Response.noContent().build();
    }

    @POST
    @Path("/creditos")
    @RolesAllowed({ "COLABORADOR", "ADMINISTRADOR" })
    public Response cadastrarCredito(@Valid CadastroCreditoEdicaoDTO dto) {
        CreditoEdicaoRespostaDTO credito = creditoEdicaoService.cadastrar(dto);
        return Response.created(URI.create("/criadores/creditos/" + credito.id()))
                .entity(credito)
                .build();
    }

    @GET
    @Path("/{id}/edicoes")
    public Response listarEdicoesPorCriador(@PathParam("id") Long id, @QueryParam("papel") PapelCriador papel) {
        List<CreditoEdicaoRespostaDTO> creditos = creditoEdicaoService.listarEdicoesPorCriador(id, papel);
        return Response.ok(creditos).build();
    }

    @DELETE
    @Path("/creditos/{id}")
    @RolesAllowed("ADMINISTRADOR")
    public Response removerCredito(@PathParam("id") Long id) {
        creditoEdicaoService.remover(id);
        return Response.noContent().build();
    }
}

