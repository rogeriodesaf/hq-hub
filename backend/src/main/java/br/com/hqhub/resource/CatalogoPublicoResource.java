package br.com.hqhub.resource;

import java.util.List;

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

    private static final String URL_BASE = "https://hqhub.space";
    private static final List<String> PAGINAS_FIXAS = List.of(
            "/",
            "/catalogo",
            "/classificados",
            "/guia-de-leitura-app/ordem-de-leitura-mutante",
            "/guia-de-leitura-app/batman-ordem-cronologica",
            "/guia-de-leitura-app/tex-ordem-publicacao-brasileira",
            "/guia-de-leitura-app/colecao-marvel-deluxe-capa-preta",
            "/guia-de-leitura-app/marvel-omnibus",
            "/guia-de-leitura-app/colecao-nova-marvel");

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

    @GET
    @Path("/sitemap.xml")
    @Produces("application/xml")
    public Response obterSitemap() {
        StringBuilder xml = new StringBuilder("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
                .append("<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n");
        PAGINAS_FIXAS.forEach(caminho -> adicionarUrl(xml, caminho));
        serieRepository.listarIdsParaSitemap().forEach(id -> adicionarUrl(xml, "/colecao/serie/" + id));
        edicaoRepository.listarIdsParaSitemap().forEach(id -> adicionarUrl(xml, "/e/" + id));
        xml.append("</urlset>\n");

        CacheControl cache = new CacheControl();
        cache.setMaxAge(3600);
        return Response.ok(xml.toString(), "application/xml")
                .cacheControl(cache)
                .build();
    }

    private void adicionarUrl(StringBuilder xml, String caminho) {
        xml.append("  <url><loc>")
                .append(URL_BASE)
                .append(caminho)
                .append("</loc></url>\n");
    }
}
