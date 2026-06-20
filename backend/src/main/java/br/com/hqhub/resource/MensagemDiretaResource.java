package br.com.hqhub.resource;

import java.net.URI;

import br.com.hqhub.dto.CadastroMensagemDiretaDTO;
import br.com.hqhub.dto.TotalNaoLidasDTO;
import br.com.hqhub.service.MensagemDiretaService;
import io.quarkus.security.Authenticated;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/mensagens")
@Authenticated
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class MensagemDiretaResource {

    private final MensagemDiretaService mensagemDiretaService;

    public MensagemDiretaResource(MensagemDiretaService mensagemDiretaService) {
        this.mensagemDiretaService = mensagemDiretaService;
    }

    @GET
    @Path("/conversas")
    public Response listarConversas() {
        return Response.ok(mensagemDiretaService.listarConversas()).build();
    }

    @GET
    @Path("/usuarios/{usuarioId}")
    public Response listarConversa(@PathParam("usuarioId") Long usuarioId) {
        return Response.ok(mensagemDiretaService.listarConversa(usuarioId)).build();
    }

    @GET
    @Path("/nao-lidas/total")
    public Response contarNaoLidas() {
        return Response.ok(new TotalNaoLidasDTO(mensagemDiretaService.contarNaoLidas())).build();
    }

    @POST
    public Response enviar(@Valid CadastroMensagemDiretaDTO dto) {
        var resposta = mensagemDiretaService.enviar(dto);
        return Response.created(URI.create("/mensagens/" + resposta.id()))
                .entity(resposta)
                .build();
    }
}
