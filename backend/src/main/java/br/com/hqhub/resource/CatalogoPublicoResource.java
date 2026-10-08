package br.com.hqhub.resource;

import br.com.hqhub.dto.EstatisticasCatalogoDTO;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.SerieRepository;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.CacheControl;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/catalogo-publico")
@Produces(MediaType.APPLICATION_JSON)
public class CatalogoPublicoResource {

    private final SerieRepository serieRepository;
    private final EdicaoRepository edicaoRepository;

    public CatalogoPublicoResource(
            SerieRepository serieRepository,
            EdicaoRepository edicaoRepository) {
        this.serieRepository = serieRepository;
        this.edicaoRepository = edicaoRepository;
    }

    @GET
    @Path("/estatisticas")
    public Response obterEstatisticas() {
        CacheControl cache = new CacheControl();
        cache.setMaxAge(30);

        return Response.ok(new EstatisticasCatalogoDTO(
                serieRepository.count(),
                edicaoRepository.count()))
                .cacheControl(cache)
                .build();
    }
}
