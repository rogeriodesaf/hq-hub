package br.com.hqhub.resource;

import br.com.hqhub.entity.PerfilUsuario;
import br.com.hqhub.service.UsuarioAutenticadoService;
import io.quarkus.security.Authenticated;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.core.Response;
import java.net.URI;

@Path("/instalador")
@Authenticated
public class InstaladorResource {

    private static final String URL_INSTALADOR =
            "https://github.com/rogeriodesaf/hq-hub/raw/main/instalador-hqhub/dist/HQ-HUB-Agente-Setup.exe";

    private final UsuarioAutenticadoService usuarioAutenticadoService;

    public InstaladorResource(UsuarioAutenticadoService usuarioAutenticadoService) {
        this.usuarioAutenticadoService = usuarioAutenticadoService;
    }

    @GET
    public Response baixar() {
        PerfilUsuario perfil = usuarioAutenticadoService.obterUsuario().getPerfil();
        if (perfil != PerfilUsuario.COLABORADOR && perfil != PerfilUsuario.ADMINISTRADOR) {
            return Response.status(Response.Status.FORBIDDEN).build();
        }
        return Response.temporaryRedirect(URI.create(URL_INSTALADOR)).build();
    }
}
