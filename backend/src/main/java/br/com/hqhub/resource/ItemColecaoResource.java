package br.com.hqhub.resource;

import java.net.URI;
import java.util.List;

import br.com.hqhub.dto.AtualizacaoItemColecaoDTO;
import br.com.hqhub.dto.CadastroItemColecaoDTO;
import br.com.hqhub.dto.ItemColecaoRespostaDTO;
import br.com.hqhub.service.ItemColecaoService;
import io.quarkus.security.Authenticated;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/colecao/itens")
@Authenticated
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class ItemColecaoResource {

    private final ItemColecaoService itemColecaoService;

    public ItemColecaoResource(ItemColecaoService itemColecaoService) {
        this.itemColecaoService = itemColecaoService;
    }

    @POST
    public Response cadastrar(@Valid CadastroItemColecaoDTO dto) {
        ItemColecaoRespostaDTO item = itemColecaoService.cadastrar(dto);
        return Response.created(URI.create("/colecao/itens/" + item.id()))
                .entity(item)
                .build();
    }

    @GET
    @Path("/{id}")
    public Response buscarPorId(@PathParam("id") Long id) {
        ItemColecaoRespostaDTO item = itemColecaoService.buscarPorId(id);
        return Response.ok(item).build();
    }

    @GET
    public Response listarTodos() {
        List<ItemColecaoRespostaDTO> itens = itemColecaoService.listarTodos();
        return Response.ok(itens).build();
    }

    @PUT
    @Path("/{id}")
    public Response atualizar(@PathParam("id") Long id, @Valid AtualizacaoItemColecaoDTO dto) {
        ItemColecaoRespostaDTO item = itemColecaoService.atualizar(id, dto);
        return Response.ok(item).build();
    }

    @DELETE
    @Path("/{id}")
    public Response remover(@PathParam("id") Long id) {
        itemColecaoService.remover(id);
        return Response.noContent().build();
    }
}
