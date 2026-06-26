package br.com.hqhub.resource;

import java.net.URI;
import java.util.List;

import br.com.hqhub.dto.AtualizacaoCompraPlanejadaDTO;
import br.com.hqhub.dto.CadastroCompraPlanejadaDTO;
import br.com.hqhub.dto.CompraPlanejadaRespostaDTO;
import br.com.hqhub.service.CompraPlanejadaService;
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

@Path("/compras-planejadas")
@Authenticated
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class CompraPlanejadaResource {

    private final CompraPlanejadaService compraPlanejadaService;

    public CompraPlanejadaResource(CompraPlanejadaService compraPlanejadaService) {
        this.compraPlanejadaService = compraPlanejadaService;
    }

    @POST
    public Response cadastrar(@Valid CadastroCompraPlanejadaDTO dto) {
        CompraPlanejadaRespostaDTO resposta = compraPlanejadaService.cadastrar(dto);
        return Response.created(URI.create("/compras-planejadas/" + resposta.id()))
                .entity(resposta)
                .build();
    }

    @GET
    @Path("/{id}")
    public Response buscarPorId(@PathParam("id") Long id) {
        return Response.ok(compraPlanejadaService.buscarPorId(id)).build();
    }

    @GET
    public Response listar(
            @QueryParam("mes") Integer mes,
            @QueryParam("ano") Integer ano,
            @QueryParam("mesInicio") Integer mesInicio,
            @QueryParam("anoInicio") Integer anoInicio,
            @QueryParam("mesFim") Integer mesFim,
            @QueryParam("anoFim") Integer anoFim) {
        List<CompraPlanejadaRespostaDTO> compras = compraPlanejadaService.listar(mes, ano, mesInicio, anoInicio, mesFim, anoFim);
        return Response.ok(compras).build();
    }

    @PUT
    @Path("/{id}")
    public Response atualizar(@PathParam("id") Long id, @Valid AtualizacaoCompraPlanejadaDTO dto) {
        return Response.ok(compraPlanejadaService.atualizar(id, dto)).build();
    }

    @DELETE
    @Path("/{id}")
    public Response remover(@PathParam("id") Long id) {
        compraPlanejadaService.remover(id);
        return Response.noContent().build();
    }
}
