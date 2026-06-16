package br.com.hqhub.resource;

import java.math.BigDecimal;
import java.time.LocalDate;

import br.com.hqhub.service.CalculadoraInflacaoService;
import io.quarkus.security.Authenticated;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/calculadora-inflacao")
@Authenticated
@Produces(MediaType.APPLICATION_JSON)
public class CalculadoraInflacaoResource {

    private final CalculadoraInflacaoService calculadoraInflacaoService;

    public CalculadoraInflacaoResource(CalculadoraInflacaoService calculadoraInflacaoService) {
        this.calculadoraInflacaoService = calculadoraInflacaoService;
    }

    @GET
    public Response calcular(@QueryParam("valor") BigDecimal valor, @QueryParam("dataReferencia") String dataReferencia) {
        LocalDate data = dataReferencia == null || dataReferencia.isBlank() ? null : LocalDate.parse(dataReferencia);
        return Response.ok(calculadoraInflacaoService.calcular(valor, data)).build();
    }
}
