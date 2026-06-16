package br.com.hqhub.resource;

import java.net.URI;
import java.util.List;

import br.com.hqhub.dto.CadastroUsuarioDTO;
import br.com.hqhub.dto.UsuarioRespostaDTO;
import br.com.hqhub.service.UsuarioService;
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

@Path("/usuarios")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class UsuarioResource {

    private final UsuarioService usuarioService;

    public UsuarioResource(UsuarioService usuarioService) {
        this.usuarioService = usuarioService;
    }

    @POST
    public Response cadastrar(@Valid CadastroUsuarioDTO dto) {
        UsuarioRespostaDTO usuario = usuarioService.cadastrar(dto);
        return Response.created(URI.create("/usuarios/" + usuario.id()))
                .entity(usuario)
                .build();
    }

    @GET
    @Path("/{id}")
    @Authenticated
    public Response buscarPorId(@PathParam("id") Long id) {
        UsuarioRespostaDTO usuario = usuarioService.buscarPorId(id);
        return Response.ok(usuario).build();
    }

    @GET
    @Authenticated
    public Response listarTodos() {
        List<UsuarioRespostaDTO> usuarios = usuarioService.listarTodos();
        return Response.ok(usuarios).build();
    }
}
