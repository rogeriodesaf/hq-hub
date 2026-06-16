package br.com.hqhub.resource;

import br.com.hqhub.dto.AutenticacaoUsuarioDTO;
import br.com.hqhub.dto.UsuarioAutenticadoDTO;
import br.com.hqhub.service.AutenticacaoService;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/auth")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class AutenticacaoResource {

    private final AutenticacaoService autenticacaoService;

    public AutenticacaoResource(AutenticacaoService autenticacaoService) {
        this.autenticacaoService = autenticacaoService;
    }

    @POST
    @Path("/login")
    public Response autenticar(@Valid AutenticacaoUsuarioDTO dto) {
        UsuarioAutenticadoDTO usuario = autenticacaoService.autenticar(dto);
        return Response.ok(usuario).build();
    }
}
