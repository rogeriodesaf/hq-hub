package br.com.hqhub.resource;

import java.util.List;

import br.com.hqhub.dto.ImportacaoCatalogoDTO;
import br.com.hqhub.dto.ResultadoImportacaoCatalogoDTO;
import br.com.hqhub.service.ImportacaoCatalogoService;
import io.quarkus.security.identity.SecurityIdentity;
import jakarta.annotation.security.RolesAllowed;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/importacoes/catalogo")
@RolesAllowed({ "COLABORADOR", "ADMINISTRADOR" })
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class ImportacaoCatalogoResource {

    private final ImportacaoCatalogoService importacaoCatalogoService;
    private final SecurityIdentity securityIdentity;

    public ImportacaoCatalogoResource(ImportacaoCatalogoService importacaoCatalogoService, SecurityIdentity securityIdentity) {
        this.importacaoCatalogoService = importacaoCatalogoService;
        this.securityIdentity = securityIdentity;
    }

    @POST
    public Response importar(@Valid ImportacaoCatalogoDTO dto) {
        ResultadoImportacaoCatalogoDTO resultado = importacaoCatalogoService.importar(dto);
        return Response.ok(resultado).build();
    }

    @POST
    @Path("/backfill/comic-vine/originais-guia")
    public Response preencherComicVineEdicoesOriginaisGuia(
            @QueryParam("limite") Integer limite,
            @QueryParam("serie") String serie,
            @QueryParam("numero") String numero) {
        if (!securityIdentity.hasRole("ADMINISTRADOR")) {
            return Response.status(Response.Status.FORBIDDEN).build();
        }

        try {
            ResultadoImportacaoCatalogoDTO resultado = importacaoCatalogoService
                    .preencherComicVineEdicoesOriginaisGuia(limite, serie, numero);
            return Response.ok(resultado).build();
        } catch (Throwable e) {
            return Response.ok(new ResultadoImportacaoCatalogoDTO(
                    null,
                    "Backfill Comic Vine",
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    List.of("Falha geral no backfill: " + e.getClass().getSimpleName() + " - " + e.getMessage())))
                    .build();
        }
    }
}
