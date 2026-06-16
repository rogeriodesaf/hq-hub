package br.com.hqhub.resource;

import br.com.hqhub.dto.AtualizacaoConfiguracaoColecaoDTO;
import br.com.hqhub.service.ConfiguracaoColecaoService;
import io.quarkus.security.Authenticated;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/colecao")
@Authenticated
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class ConfiguracaoColecaoResource {

    private final ConfiguracaoColecaoService configuracaoColecaoService;

    public ConfiguracaoColecaoResource(ConfiguracaoColecaoService configuracaoColecaoService) {
        this.configuracaoColecaoService = configuracaoColecaoService;
    }

    @GET
    @Path("/configuracao")
    public Response obterMinhaConfiguracao() {
        return Response.ok(configuracaoColecaoService.obterMinhaConfiguracao()).build();
    }

    @PUT
    @Path("/configuracao")
    public Response atualizar(@Valid AtualizacaoConfiguracaoColecaoDTO dto) {
        return Response.ok(configuracaoColecaoService.atualizar(dto)).build();
    }

    @GET
    @Path("/usuarios/{usuarioId}")
    public Response visualizarColecao(@PathParam("usuarioId") Long usuarioId) {
        return Response.ok(configuracaoColecaoService.visualizarColecao(usuarioId)).build();
    }
}
