package br.com.hqhub.resource;

import br.com.hqhub.dto.ImportacaoCatalogoDTO;
import br.com.hqhub.dto.ResultadoImportacaoCatalogoDTO;
import br.com.hqhub.service.ImportacaoCatalogoService;
import jakarta.annotation.security.RolesAllowed;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/importacoes/catalogo")
@RolesAllowed({ "COLABORADOR", "ADMINISTRADOR" })
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class ImportacaoCatalogoResource {

    private final ImportacaoCatalogoService importacaoCatalogoService;

    public ImportacaoCatalogoResource(ImportacaoCatalogoService importacaoCatalogoService) {
        this.importacaoCatalogoService = importacaoCatalogoService;
    }

    @POST
    public Response importar(@Valid ImportacaoCatalogoDTO dto) {
        ResultadoImportacaoCatalogoDTO resultado = importacaoCatalogoService.importar(dto);
        return Response.ok(resultado).build();
    }

    @POST
    @Path("/backfill/comic-vine/originais-guia")
    @RolesAllowed("ADMINISTRADOR")
    public Response preencherComicVineEdicoesOriginaisGuia() {
        ResultadoImportacaoCatalogoDTO resultado = importacaoCatalogoService.preencherComicVineEdicoesOriginaisGuia();
        return Response.ok(resultado).build();
    }
}
