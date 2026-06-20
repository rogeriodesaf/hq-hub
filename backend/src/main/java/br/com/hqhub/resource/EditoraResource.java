package br.com.hqhub.resource;

import java.net.URI;
import java.util.List;

import br.com.hqhub.dto.AtualizacaoEditoraDTO;
import br.com.hqhub.dto.CadastroEditoraDTO;
import br.com.hqhub.dto.EditoraRespostaDTO;
import br.com.hqhub.service.EditoraService;
import io.quarkus.security.Authenticated;
import jakarta.annotation.security.RolesAllowed;
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

@Path("/editoras")
@Authenticated
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class EditoraResource {

    private final EditoraService editoraService;

    public EditoraResource(EditoraService editoraService) {
        this.editoraService = editoraService;
    }

    @POST
    public Response cadastrar(@Valid CadastroEditoraDTO dto) {
        EditoraRespostaDTO editora = editoraService.cadastrar(dto);
        return Response.created(URI.create("/editoras/" + editora.id()))
                .entity(editora)
                .build();
    }

    @GET
    @Path("/{id}")
    public Response buscarPorId(@PathParam("id") Long id) {
        EditoraRespostaDTO editora = editoraService.buscarPorId(id);
        return Response.ok(editora).build();
    }

    @GET
    public Response listarTodos() {
        List<EditoraRespostaDTO> editoras = editoraService.listarTodos();
        return Response.ok(editoras).build();
    }

    @PUT
    @Path("/{id}")
    @RolesAllowed({ "COLABORADOR", "ADMINISTRADOR" })
    public Response atualizar(@PathParam("id") Long id, @Valid AtualizacaoEditoraDTO dto) {
        EditoraRespostaDTO editora = editoraService.atualizar(id, dto);
        return Response.ok(editora).build();
    }

    @DELETE
    @Path("/{id}")
    @RolesAllowed({ "COLABORADOR", "ADMINISTRADOR" })
    public Response remover(@PathParam("id") Long id) {
        editoraService.remover(id);
        return Response.noContent().build();
    }
}
