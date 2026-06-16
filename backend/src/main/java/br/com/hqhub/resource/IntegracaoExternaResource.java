package br.com.hqhub.resource;

import br.com.hqhub.service.IntegracaoExternaService;
import io.quarkus.security.Authenticated;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/integracoes-externas")
@Authenticated
@Produces(MediaType.APPLICATION_JSON)
public class IntegracaoExternaResource {

    private final IntegracaoExternaService integracaoExternaService;

    public IntegracaoExternaResource(IntegracaoExternaService integracaoExternaService) {
        this.integracaoExternaService = integracaoExternaService;
    }

    @GET
    @Path("/fontes")
    public Response listarFontes() {
        return Response.ok(integracaoExternaService.listarFontes()).build();
    }

    @GET
    @Path("/{fonteExterna}/buscar")
    public Response buscar(@PathParam("fonteExterna") String fonteExterna, @QueryParam("termo") String termo) {
        return Response.ok(integracaoExternaService.buscar(fonteExterna, termo)).build();
    }

    @GET
    @Path("/COMICVINE/volumes")
    public Response buscarVolumesComicVine(
            @QueryParam("termo") String termo,
            @QueryParam("pagina") Integer pagina,
            @QueryParam("tamanho") Integer tamanho) {
        return Response.ok(integracaoExternaService.buscarVolumesComicVine(termo, pagina, tamanho)).build();
    }

    @GET
    @Path("/COMICVINE/volumes/{idVolume}/edicoes")
    public Response buscarEdicoesVolumeComicVine(
            @PathParam("idVolume") String idVolume,
            @QueryParam("pagina") Integer pagina,
            @QueryParam("tamanho") Integer tamanho) {
        return Response.ok(integracaoExternaService.buscarEdicoesVolumeComicVine(idVolume, pagina, tamanho)).build();
    }

    @GET
    @Path("/COMICVINE/edicoes/{idEdicao}/detalhes")
    public Response buscarDetalheEdicaoComicVine(@PathParam("idEdicao") String idEdicao) {
        return Response.ok(integracaoExternaService.buscarDetalheEdicaoComicVine(idEdicao)).build();
    }
}
