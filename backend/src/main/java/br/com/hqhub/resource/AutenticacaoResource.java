package br.com.hqhub.resource;

import br.com.hqhub.dto.AutenticacaoUsuarioDTO;
import br.com.hqhub.dto.RedefinicaoSenhaDTO;
import br.com.hqhub.dto.SolicitacaoRedefinicaoSenhaDTO;
import br.com.hqhub.dto.UsuarioAutenticadoDTO;
import br.com.hqhub.dto.RenovacaoSessaoDTO;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.exception.RespostaErroDTO;
import br.com.hqhub.service.AutenticacaoService;
import br.com.hqhub.service.EmailRedefinicaoSenhaService;
import br.com.hqhub.service.RedefinicaoSenhaService;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.jboss.logging.Logger;
import java.time.LocalDateTime;

@Path("/auth")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class AutenticacaoResource {
    private static final Logger LOG = Logger.getLogger(AutenticacaoResource.class);
    private final AutenticacaoService autenticacaoService;
    private final RedefinicaoSenhaService redefinicaoSenhaService;

    public AutenticacaoResource(AutenticacaoService autenticacaoService,
            RedefinicaoSenhaService redefinicaoSenhaService) {
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
    @Path("/renovar")
    public Response renovar(RenovacaoSessaoDTO dto) {
        return Response.ok(autenticacaoService.renovar(dto == null ? null : dto.refreshToken())).build();
    }

    @POST
    @Path("/sair")
    public Response sair(RenovacaoSessaoDTO dto) {
        autenticacaoService.sair(dto == null ? null : dto.refreshToken());
        return Response.noContent().build();
    }

    @POST
    @Path("/redefinir-senha/solicitar")
    public Response solicitarRedefinicao(@Valid SolicitacaoRedefinicaoSenhaDTO dto) {
        try {
            redefinicaoSenhaService.solicitar(dto);
        } catch (Exception excecao) {
            // Nunca diferenciar conta existente de inexistente, nem registrar dados pessoais,
            // credenciais, token ou mensagem da exceção (que pode conter o link).
            String codigo = excecao instanceof EmailRedefinicaoSenhaService.Falha falha
                    ? falha.codigo() : excecao.getClass().getSimpleName();
            LOG.errorf("Falha na recuperação de senha: %s", codigo);
        }
        return Response.ok().build();
    }

    @POST
    @Path("/redefinir-senha/confirmar")
    public Response confirmarRedefinicao(@Valid RedefinicaoSenhaDTO dto) {
        try {
            redefinicaoSenhaService.redefinir(dto);
            return Response.ok().build();
        } catch (RegraNegocioException excecao) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity(new RespostaErroDTO("Token inválido ou expirado.", 400, LocalDateTime.now()))
                    .build();
        } catch (Exception excecao) {
            LOG.errorf("Falha ao confirmar recuperação de senha: %s", excecao.getClass().getSimpleName());
            return Response.serverError()
                    .entity(new RespostaErroDTO("Não foi possível redefinir a senha agora.", 500, LocalDateTime.now()))
                    .build();
        }
    }
}
