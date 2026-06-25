package br.com.hqhub.resource;

import br.com.hqhub.service.NormalizacaoTextoService;
import jakarta.annotation.security.RolesAllowed;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/admin/normalizacao-texto")
@Produces(MediaType.APPLICATION_JSON)
@RolesAllowed("ADMINISTRADOR")
public class NormalizacaoTextoResource {

    private final NormalizacaoTextoService normalizacaoTextoService;

    public NormalizacaoTextoResource(NormalizacaoTextoService normalizacaoTextoService) {
        this.normalizacaoTextoService = normalizacaoTextoService;
    }

    @POST
    @Path("/catalogo")
    public Response normalizarCatalogo() {
        return Response.ok(normalizacaoTextoService.normalizarCatalogo()).build();
    }
}
