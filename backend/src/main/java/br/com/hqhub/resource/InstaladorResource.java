package br.com.hqhub.resource;

import br.com.hqhub.entity.PerfilUsuario;
import br.com.hqhub.service.UsuarioAutenticadoService;
import io.quarkus.security.Authenticated;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.MediaType;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

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
        try {
            HttpClient cliente = HttpClient.newBuilder()
                    .followRedirects(HttpClient.Redirect.NORMAL)
                    .build();
            HttpRequest requisicao = HttpRequest.newBuilder(URI.create(URL_INSTALADOR)).GET().build();
            byte[] arquivo = cliente.send(requisicao, HttpResponse.BodyHandlers.ofByteArray()).body();
            return Response.ok(arquivo, MediaType.APPLICATION_OCTET_STREAM)
                    .header("Content-Disposition", "attachment; filename=HQ-HUB-Agente-Setup.exe")
                    .build();
        } catch (Exception excecao) {
            return Response.serverError().entity("Não foi possível preparar o instalador.").build();
        }
    }
}
