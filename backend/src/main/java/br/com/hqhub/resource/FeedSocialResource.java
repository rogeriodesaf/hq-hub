package br.com.hqhub.resource;

import br.com.hqhub.dto.CadastroComentarioFeedDTO;
import br.com.hqhub.dto.CadastroPostagemFeedDTO;
import br.com.hqhub.service.FeedMidiaService;
import br.com.hqhub.service.FeedSocialService;
import io.quarkus.security.Authenticated;
import jakarta.validation.Valid;
import org.jboss.resteasy.reactive.RestForm;
import org.jboss.resteasy.reactive.multipart.FileUpload;

import java.util.List;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/feed")
@Authenticated
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class FeedSocialResource {

    private final FeedSocialService feedSocialService;
    private final FeedMidiaService feedMidiaService;

    public FeedSocialResource(FeedSocialService feedSocialService, FeedMidiaService feedMidiaService) {
        this.feedSocialService = feedSocialService;
        this.feedMidiaService = feedMidiaService;
    }

    @GET
    public Response listar(@QueryParam("pagina") Integer pagina, @QueryParam("tamanho") Integer tamanho) {
        return Response.ok(feedSocialService.listarFeed(
                pagina == null ? 0 : pagina,
                tamanho == null ? 20 : tamanho))
                .build();
    }

    @POST
    public Response publicar(@Valid CadastroPostagemFeedDTO dto) {
        return Response.ok(feedSocialService.publicar(dto)).build();
    }

    @POST
    @Path("/imagens")
    @Consumes(MediaType.MULTIPART_FORM_DATA)
    public Response enviarImagens(@RestForm("imagens") List<FileUpload> imagens) {
        return Response.ok(feedMidiaService.salvarImagens(imagens)).build();
    }

    @POST
    @Path("/{id}/curtidas")
    public Response alternarCurtida(@PathParam("id") Long id) {
        return Response.ok(feedSocialService.alternarCurtida(id)).build();
    }

    @POST
    @Path("/{id}/comentarios")
    public Response comentar(@PathParam("id") Long id, @Valid CadastroComentarioFeedDTO dto) {
        return Response.ok(feedSocialService.comentar(id, dto)).build();
    }
}
