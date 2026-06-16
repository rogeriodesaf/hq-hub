package br.com.hqhub.resource;

import java.net.URI;
import java.util.List;

import br.com.hqhub.dto.CadastroConversaAssistenteDTO;
import br.com.hqhub.dto.ConversaAssistenteDetalheDTO;
import br.com.hqhub.dto.ConversaAssistenteRespostaDTO;
import br.com.hqhub.dto.EnvioMensagemAssistenteDTO;
import br.com.hqhub.dto.PerguntaAssistenteDTO;
import br.com.hqhub.dto.RespostaAssistenteDTO;
import br.com.hqhub.dto.RespostaConversaAssistenteDTO;
import br.com.hqhub.service.AssistenteService;
import br.com.hqhub.service.ConversaAssistenteService;
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

@Path("/assistente")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
@Authenticated
public class AssistenteResource {

    private final AssistenteService assistenteService;
    private final ConversaAssistenteService conversaAssistenteService;

    public AssistenteResource(AssistenteService assistenteService, ConversaAssistenteService conversaAssistenteService) {
        this.assistenteService = assistenteService;
        this.conversaAssistenteService = conversaAssistenteService;
    }

    @POST
    @Path("/perguntar")
    public Response perguntar(@Valid PerguntaAssistenteDTO dto) {
        RespostaAssistenteDTO resposta = assistenteService.responder(dto.pergunta());
        return Response.ok(resposta).build();
    }

    @POST
    @Path("/conversas")
    public Response criarConversa(@Valid CadastroConversaAssistenteDTO dto) {
        ConversaAssistenteRespostaDTO resposta = conversaAssistenteService.criar(dto);
        return Response.created(URI.create("/assistente/conversas/" + resposta.id()))
                .entity(resposta)
                .build();
    }

    @GET
    @Path("/conversas")
    public Response listarConversas() {
        List<ConversaAssistenteRespostaDTO> conversas = conversaAssistenteService.listar();
        return Response.ok(conversas).build();
    }

    @GET
    @Path("/conversas/{id}")
    public Response buscarConversa(@PathParam("id") Long id) {
        ConversaAssistenteDetalheDTO conversa = conversaAssistenteService.buscarPorId(id);
        return Response.ok(conversa).build();
    }

    @POST
    @Path("/conversas/{id}/mensagens")
    public Response enviarMensagem(@PathParam("id") Long id, @Valid EnvioMensagemAssistenteDTO dto) {
        RespostaConversaAssistenteDTO resposta = conversaAssistenteService.enviarMensagem(id, dto);
        return Response.ok(resposta).build();
    }
}
