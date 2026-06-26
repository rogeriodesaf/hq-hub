package br.com.hqhub.resource;

import java.util.List;

import br.com.hqhub.dto.CadastroConhecimentoEditorialDTO;
import br.com.hqhub.dto.ConhecimentoEditorialDTO;
import br.com.hqhub.dto.ResultadoBuscaConhecimentoDTO;
import br.com.hqhub.service.ConhecimentoEditorialService;
import br.com.hqhub.service.ScrapingComicVineService;
import jakarta.ws.rs.BadRequestException;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.NotFoundException;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/api/conhecimentos-editoriais")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class ConhecimentoEditorialResource {

    private final ConhecimentoEditorialService service;
    private final ScrapingComicVineService scrapingService;

    public ConhecimentoEditorialResource(ConhecimentoEditorialService service, ScrapingComicVineService scrapingService) {
        this.service = service;
        this.scrapingService = scrapingService;
    }

    @POST
    public Response criar(CadastroConhecimentoEditorialDTO dto) {
        if (dto.titulo() == null || dto.titulo().isBlank()) {
            throw new BadRequestException("Título é obrigatório");
        }

        ConhecimentoEditorialDTO resultado = service.cadastrar(dto);
        return Response.status(Response.Status.CREATED).entity(resultado).build();
    }

    @GET
    @Path("/{id}")
    public ConhecimentoEditorialDTO buscarPorId(@PathParam("id") Long id) {
        ConhecimentoEditorialDTO resultado = service.buscarPorId(id);
        if (resultado == null) {
            throw new NotFoundException("Conhecimento editorial não encontrado");
        }
        return resultado;
    }

    @PUT
    @Path("/{id}")
    public ConhecimentoEditorialDTO atualizar(@PathParam("id") Long id, CadastroConhecimentoEditorialDTO dto) {
        ConhecimentoEditorialDTO resultado = service.atualizar(id, dto);
        if (resultado == null) {
            throw new NotFoundException("Conhecimento editorial não encontrado");
        }
        return resultado;
    }

    @DELETE
    @Path("/{id}")
    public Response deletar(@PathParam("id") Long id) {
        service.deletar(id);
        return Response.noContent().build();
    }

    @GET
    @Path("/buscar")
    public List<ResultadoBuscaConhecimentoDTO> buscar(@QueryParam("q") String pergunta) {
        if (pergunta == null || pergunta.isBlank()) {
            throw new BadRequestException("Parâmetro 'q' é obrigatório");
        }
        return service.buscarRelevante(pergunta);
    }

    @GET
    @Path("/tipo/{tipo}")
    public List<ResultadoBuscaConhecimentoDTO> buscarPorTipo(@PathParam("tipo") String tipo) {
        return service.buscarPorTipo(tipo);
    }

    @POST
    @Path("/scraping/serie/{nome}")
    public Response importarSeriePorNome(@PathParam("nome") String nome) {
        scrapingService.importarSerie(nome);
        return Response.ok("Série importada do Comic Vine").build();
    }

    @POST
    @Path("/scraping/personagem/{nome}")
    public Response importarPersonagemPorNome(@PathParam("nome") String nome) {
        scrapingService.importarPersonagem(nome);
        return Response.ok("Personagem importado do Comic Vine").build();
    }

    @POST
    @Path("/scraping/criador/{nome}")
    public Response importarCriadorPorNome(@PathParam("nome") String nome) {
        scrapingService.importarCriador(nome);
        return Response.ok("Criador importado do Comic Vine").build();
    }
}
