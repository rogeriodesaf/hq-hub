package br.com.hqhub.resource;

import java.nio.file.Files;

import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.service.FeedMidiaService;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.Response;

@Path("/midia/feed")
public class MidiaFeedResource {

    private final FeedMidiaService feedMidiaService;

    public MidiaFeedResource(FeedMidiaService feedMidiaService) {
        this.feedMidiaService = feedMidiaService;
    }

    @GET
    @Path("/{arquivo}")
    @Produces({ "image/jpeg", "image/png", "image/webp" })
    public Response buscar(@PathParam("arquivo") String arquivo) {
        java.nio.file.Path caminho = feedMidiaService.buscarArquivo(arquivo);
        if (!Files.exists(caminho)) {
            throw new RecursoNaoEncontradoException("Imagem nao encontrada.");
        }
        return Response.ok(caminho.toFile()).type(tipoMime(caminho)).build();
    }

    private String tipoMime(java.nio.file.Path caminho) {
        String nome = caminho.getFileName().toString().toLowerCase();
        if (nome.endsWith(".webp")) {
            return "image/webp";
        }
        if (nome.endsWith(".png")) {
            return "image/png";
        }
        return "image/jpeg";
    }
}
