package br.com.hqhub.resource;

import java.net.URI;
import java.util.List;

import br.com.hqhub.dto.AmizadeRespostaDTO;
import br.com.hqhub.dto.BloqueioUsuarioDTO;
import br.com.hqhub.dto.BloqueioUsuarioRespostaDTO;
import br.com.hqhub.dto.CadastroSolicitacaoAmizadeDTO;
import br.com.hqhub.dto.TotalNaoLidasDTO;
import br.com.hqhub.service.AmizadeService;
import io.quarkus.security.Authenticated;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/amizades")
@Authenticated
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class AmizadeResource {

    private final AmizadeService amizadeService;

    public AmizadeResource(AmizadeService amizadeService) {
        this.amizadeService = amizadeService;
    }

    @POST
    @Path("/solicitacoes")
    public Response enviarSolicitacao(@Valid CadastroSolicitacaoAmizadeDTO dto) {
        AmizadeRespostaDTO resposta = amizadeService.enviarSolicitacao(dto);
        return Response.created(URI.create("/amizades/solicitacoes/" + resposta.id()))
                .entity(resposta)
                .build();
    }

    @GET
    @Path("/amigos")
    public Response listarAmigos() {
        List<AmizadeRespostaDTO> amigos = amizadeService.listarAmigos();
        return Response.ok(amigos).build();
    }

    @DELETE
    @Path("/amigos/{usuarioId}")
    public Response removerAmigo(@PathParam("usuarioId") Long usuarioId) {
        amizadeService.removerAmigo(usuarioId);
        return Response.noContent().build();
    }

    @GET
    @Path("/solicitacoes/recebidas")
    public Response listarRecebidas() {
        return Response.ok(amizadeService.listarSolicitacoesPendentesRecebidas()).build();
    }

    @GET
    @Path("/solicitacoes/recebidas/total")
    public Response contarRecebidas() {
        return Response.ok(new TotalNaoLidasDTO(amizadeService.contarSolicitacoesPendentesRecebidas())).build();
    }

    @GET
    @Path("/solicitacoes/enviadas")
    public Response listarEnviadas() {
        return Response.ok(amizadeService.listarSolicitacoesPendentesEnviadas()).build();
    }

    @POST
    @Path("/solicitacoes/{id}/aceitar")
    public Response aceitar(@PathParam("id") Long id) {
        return Response.ok(amizadeService.aceitar(id)).build();
    }

    @POST
    @Path("/solicitacoes/{id}/recusar")
    public Response recusar(@PathParam("id") Long id) {
        return Response.ok(amizadeService.recusar(id)).build();
    }

    @POST
    @Path("/bloqueios")
    public Response bloquear(@Valid BloqueioUsuarioDTO dto) {
        BloqueioUsuarioRespostaDTO resposta = amizadeService.bloquear(dto);
        return Response.created(URI.create("/amizades/bloqueios/" + resposta.id()))
                .entity(resposta)
                .build();
    }

    @GET
    @Path("/bloqueios")
    public Response listarBloqueios() {
        return Response.ok(amizadeService.listarBloqueios()).build();
    }

    @DELETE
    @Path("/bloqueios/usuarios/{usuarioId}")
    public Response desbloquear(@PathParam("usuarioId") Long usuarioId) {
        amizadeService.desbloquear(usuarioId);
        return Response.noContent().build();
    }
}
