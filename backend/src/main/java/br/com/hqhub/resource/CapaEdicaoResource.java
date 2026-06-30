package br.com.hqhub.resource;

import java.util.List;

import br.com.hqhub.dto.ImportacaoCapaJsonDTO;
import br.com.hqhub.service.CapaEdicaoService;
import io.quarkus.security.Authenticated;
import jakarta.annotation.security.RolesAllowed;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.PATCH;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/capas")
@Authenticated
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class CapaEdicaoResource {

    private final CapaEdicaoService capaEdicaoService;

    public CapaEdicaoResource(CapaEdicaoService capaEdicaoService) {
        this.capaEdicaoService = capaEdicaoService;
    }

    @POST
    @Path("/importar-json")
    @RolesAllowed({ "COLABORADOR", "ADMINISTRADOR" })
    public Response importarJson(@Valid List<ImportacaoCapaJsonDTO> itens) {
        return Response.ok(capaEdicaoService.importarJson(itens)).build();
    }

    @PATCH
    @Path("/{id}/aprovar")
    @RolesAllowed({ "COLABORADOR", "ADMINISTRADOR" })
    public Response aprovar(@PathParam("id") Long id) {
        return Response.ok(capaEdicaoService.aprovar(id)).build();
    }

    @PATCH
    @Path("/{id}/rejeitar")
    @RolesAllowed({ "COLABORADOR", "ADMINISTRADOR" })
    public Response rejeitar(@PathParam("id") Long id) {
        return Response.ok(capaEdicaoService.rejeitar(id)).build();
    }
}
