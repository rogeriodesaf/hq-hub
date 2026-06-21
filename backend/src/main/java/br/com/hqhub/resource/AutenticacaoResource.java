package br.com.hqhub.resource;

import br.com.hqhub.dto.AutenticacaoUsuarioDTO;
import br.com.hqhub.dto.RedefinicaoSenhaDTO;
import br.com.hqhub.dto.SolicitacaoRedefinicaoSenhaDTO;
import br.com.hqhub.dto.UsuarioAutenticadoDTO;
import br.com.hqhub.service.AutenticacaoService;
import br.com.hqhub.service.RedefinicaoSenhaService;
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
    private final RedefinicaoSenhaService redefinicaoSenhaService;

    public AutenticacaoResource(AutenticacaoService autenticacaoService, RedefinicaoSenhaService redefinicaoSenhaService) {
        this.autenticacaoService = autenticacaoService;
        this.redefinicaoSenhaService = redefinicaoSenhaService;
    }

    @POST
    @Path("/login")
    public Response autenticar(@Valid AutenticacaoUsuarioDTO dto) {
        UsuarioAutenticadoDTO usuario = autenticacaoService.autenticar(dto);
        return Response.ok(usuario).build();
    }

    @POST
    @Path("/redefinir-senha/solicitar")
    public Response solicitarRedefinicao(@Valid SolicitacaoRedefinicaoSenhaDTO dto) {
        redefinicaoSenhaService.solicitar(dto);
        return Response.ok().build();
    }

    @POST
    @Path("/redefinir-senha/confirmar")
    public Response confirmarRedefinicao(@Valid RedefinicaoSenhaDTO dto) {
        redefinicaoSenhaService.redefinir(dto);
        return Response.ok().build();
    }
}

