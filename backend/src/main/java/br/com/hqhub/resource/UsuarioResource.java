package br.com.hqhub.resource;

import java.net.URI;
import java.util.List;

import org.jboss.resteasy.reactive.RestForm;
import org.jboss.resteasy.reactive.multipart.FileUpload;

import br.com.hqhub.dto.AtualizacaoPerfilUsuarioDTO;
import br.com.hqhub.dto.CadastroColaboradorDTO;
import br.com.hqhub.dto.CadastroUsuarioDTO;
import br.com.hqhub.dto.ImagemFeedDTO;
import br.com.hqhub.dto.UsuarioRespostaDTO;
import br.com.hqhub.service.FeedMidiaService;
import br.com.hqhub.service.UsuarioService;
import io.quarkus.security.Authenticated;
import jakarta.annotation.security.RolesAllowed;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/usuarios")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class UsuarioResource {

    private final UsuarioService usuarioService;
    private final FeedMidiaService feedMidiaService;

    public UsuarioResource(UsuarioService usuarioService, FeedMidiaService feedMidiaService) {
        this.usuarioService = usuarioService;
        this.feedMidiaService = feedMidiaService;
    }

    @POST
    public Response cadastrar(@Valid CadastroUsuarioDTO dto) {
        UsuarioRespostaDTO usuario = usuarioService.cadastrar(dto);
        return Response.created(URI.create("/usuarios/" + usuario.id()))
                .entity(usuario)
                .build();
    }

    @POST
    @Path("/colaboradores")
    @Authenticated
    @RolesAllowed("ADMINISTRADOR")
    public Response cadastrarColaborador(@Valid CadastroColaboradorDTO dto) {
        UsuarioRespostaDTO usuario = usuarioService.cadastrarColaborador(dto);
        return Response.created(URI.create("/usuarios/" + usuario.id()))
                .entity(usuario)
                .build();
    }

    @GET
    @Path("/me")
    @Authenticated
    public Response obterMeuPerfil() {
        return Response.ok(usuarioService.obterMeuPerfil()).build();
    }

    @PUT
    @Path("/me/perfil")
    @Authenticated
    public Response atualizarMeuPerfil(@Valid AtualizacaoPerfilUsuarioDTO dto) {
        return Response.ok(usuarioService.atualizarMeuPerfil(dto)).build();
    }

    @POST
    @Path("/me/foto")
    @Authenticated
    @Consumes(MediaType.MULTIPART_FORM_DATA)
    public Response atualizarFotoPerfil(@RestForm("foto") FileUpload foto) {
        List<ImagemFeedDTO> imagens = feedMidiaService.salvarImagens(foto == null ? List.of() : List.of(foto));
        if (imagens.isEmpty()) {
            return Response.status(Response.Status.BAD_REQUEST).entity("Informe uma foto.").build();
        }
        return Response.ok(usuarioService.atualizarFotoPerfil(imagens.get(0))).build();
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
    public Response listarTodos(@QueryParam("busca") String busca) {
        List<UsuarioRespostaDTO> usuarios = usuarioService.listarTodos(busca);
        return Response.ok(usuarios).build();
    }
}
