package br.com.hqhub.resource;

import br.com.hqhub.dto.ColecaoResumoDTO;
import br.com.hqhub.dto.EstatisticasPublicasColecaoDTO;
import br.com.hqhub.dto.SerieCompletudeDTO;
import br.com.hqhub.service.ResumoColecaoService;
import io.quarkus.security.Authenticated;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/colecao/resumo")
@Authenticated
@Produces(MediaType.APPLICATION_JSON)
public class ResumoColecaoResource {

    private final ResumoColecaoService resumoColecaoService;

    public ResumoColecaoResource(ResumoColecaoService resumoColecaoService) {
        this.resumoColecaoService = resumoColecaoService;
    }

    @GET
    public Response gerarResumo() {
        ColecaoResumoDTO resumo = resumoColecaoService.gerarResumo();
        return Response.ok(resumo).build();
    }

    @GET
    @Path("/series/{serieId}")
    public Response calcularCompletudePorSerie(@PathParam("serieId") Long serieId) {
        SerieCompletudeDTO completude = resumoColecaoService.calcularCompletudePorSerie(serieId);
        return Response.ok(completude).build();
    }

    @GET
    @Path("/usuarios/{usuarioId}")
    public Response gerarEstatisticasPublicas(@PathParam("usuarioId") Long usuarioId) {
        EstatisticasPublicasColecaoDTO stats = resumoColecaoService.gerarEstatisticasPublicas(usuarioId);
        return Response.ok(stats).build();
    }
}
