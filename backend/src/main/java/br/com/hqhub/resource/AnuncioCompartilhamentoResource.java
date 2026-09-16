package br.com.hqhub.resource;

import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.math.BigDecimal;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.text.NumberFormat;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import javax.imageio.ImageIO;

import br.com.hqhub.dto.AnuncioPublicoDTO;
import br.com.hqhub.entity.TipoAnuncio;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.service.AnuncioService;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/compartilhar/anuncios")
public class AnuncioCompartilhamentoResource {
    private static final String BASE = "https://hqhub.space";
    private static final String IMAGEM_RESERVA = BASE + "/assets/classificados-hqs.jpg?v=2";
    private static final HttpClient HTTP = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(5)).followRedirects(HttpClient.Redirect.NEVER).build();
    private final AnuncioService anuncios;

    public AnuncioCompartilhamentoResource(AnuncioService anuncios) {
        this.anuncios = anuncios;
    }

    @GET
    @Path("/{id}")
    @Produces(MediaType.TEXT_HTML)
    public Response compartilhar(@PathParam("id") Long id) {
        if (id == null || id <= 0) return indisponivel();
        try {
            return Response.ok(html(anuncios.buscarAtivoPublico(id)), "text/html; charset=UTF-8")
                    .header("Cache-Control", "no-cache, must-revalidate")
                    .build();
        } catch (RecursoNaoEncontradoException erro) {
            return indisponivel();
        }
    }

    @GET
    @Path("/{id}/imagem.jpg")
    @Produces("image/jpeg")
    public Response imagem(@PathParam("id") Long id) {
        if (id == null || id <= 0) return Response.status(404).build();
        try {
            AnuncioPublicoDTO anuncio = anuncios.buscarAtivoPublico(id);
            String origem = imagemAbsoluta(anuncio.urlFotoExemplar());
            if (origem == null) origem = imagemAbsoluta(anuncio.urlCapa());
            if (origem == null || !imagemExternaPermitida(origem)) return Response.status(404).build();
            HttpRequest pedido = HttpRequest.newBuilder(URI.create(origem)).timeout(Duration.ofSeconds(8))
                    .header("Accept", "image/webp,image/jpeg,image/png").GET().build();
            HttpResponse<InputStream> resposta = HTTP.send(pedido, HttpResponse.BodyHandlers.ofInputStream());
            byte[] dados;
            try (InputStream corpo = resposta.body()) {
                if (resposta.statusCode() != 200) return Response.status(404).build();
                dados = corpo.readNBytes(5_000_001);
            }
            if (dados.length > 5_000_000) return Response.status(404).build();
            BufferedImage original = ImageIO.read(new ByteArrayInputStream(dados));
            if (original == null) return Response.status(404).build();
            double escala = Math.min(1200d / original.getWidth(), 1600d / original.getHeight());
            escala = Math.max(1d, escala);
            int largura = (int) Math.round(original.getWidth() * escala);
            int altura = (int) Math.round(original.getHeight() * escala);
            BufferedImage rgb = new BufferedImage(largura, altura, BufferedImage.TYPE_INT_RGB);
            var grafico = rgb.createGraphics();
            grafico.setColor(java.awt.Color.WHITE);
            grafico.fillRect(0, 0, largura, altura);
            grafico.setRenderingHint(java.awt.RenderingHints.KEY_INTERPOLATION,
                    java.awt.RenderingHints.VALUE_INTERPOLATION_BICUBIC);
            grafico.drawImage(original, 0, 0, largura, altura, null);
            grafico.dispose();
            ByteArrayOutputStream jpeg = new ByteArrayOutputStream();
            if (!ImageIO.write(rgb, "jpeg", jpeg)) return Response.status(404).build();
            return Response.ok(jpeg.toByteArray(), "image/jpeg")
                    .header("Cache-Control", "public, max-age=3600").build();
        } catch (Exception erro) {
            return Response.status(404).build();
        }
    }

    private Response indisponivel() {
        return Response.status(Response.Status.NOT_FOUND).type("text/html; charset=UTF-8")
                .header("Cache-Control", "no-store")
                .entity("<!doctype html><html lang=\"pt-BR\"><head><meta charset=\"utf-8\">"
                        + "<title>Anúncio indisponível | HQ-HUB</title><meta name=\"robots\" content=\"noindex\">"
                        + "</head><body><h1>Anúncio indisponível</h1><p>Este anúncio não está mais ativo.</p>"
                        + "<a href=\"https://hqhub.space/classificados\">Ver classificados</a></body></html>")
                .build();
    }

    private String html(AnuncioPublicoDTO anuncio) {
        String url = BASE + "/classificados/anuncio/" + anuncio.id();
        String destino = BASE + "/classificados?anuncioId=" + anuncio.id();
        String modalidade = modalidade(anuncio.tipoAnuncio());
        String preco = anuncio.preco() == null ? "" : " · " + moeda(anuncio.preco());
        String titulo = anuncio.tituloEdicao() + " · " + modalidade + preco + " | HQ-HUB";
        List<String> detalhes = new ArrayList<>();
        if (anuncio.estadoConservacao() != null) {
            detalhes.add("Conservação: " + anuncio.estadoConservacao().name().replace('_', ' ').toLowerCase(Locale.forLanguageTag("pt-BR")));
        }
        if (anuncio.nomeAnunciante() != null && !anuncio.nomeAnunciante().isBlank()) {
            detalhes.add("Anunciante: " + anuncio.nomeAnunciante().trim());
        }
        String descricao = String.join(" · ", detalhes);
        if (descricao.isBlank()) descricao = "Veja este anúncio nos classificados do HQ-HUB.";
        String imagem = imagemAbsoluta(anuncio.urlFotoExemplar());
        String textoImagem = "Foto do exemplar de " + anuncio.tituloEdicao();
        if (imagem == null) {
            imagem = imagemAbsoluta(anuncio.urlCapa());
            textoImagem = "Capa de " + anuncio.tituloEdicao();
        }
        if (imagem == null) {
            imagem = IMAGEM_RESERVA;
            textoImagem = "Classificados do HQ-HUB";
        } else if (imagemExternaPermitida(imagem)) {
            imagem = url + "/imagem.jpg";
        }
        return """
                <!doctype html><html lang="pt-BR"><head>
                <meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
                <title>%s</title><meta name="description" content="%s">
                <link rel="canonical" href="%s"><meta property="og:type" content="product">
                <meta property="og:site_name" content="HQ-HUB"><meta property="og:title" content="%s">
                <meta property="og:description" content="%s"><meta property="og:url" content="%s">
                <meta property="og:image" content="%s"><meta property="og:image:secure_url" content="%s">
                <meta property="og:image:alt" content="%s">
                <meta name="twitter:card" content="summary_large_image"><meta name="twitter:title" content="%s">
                <meta name="twitter:description" content="%s"><meta name="twitter:image" content="%s">
                <script>window.location.replace(%s);</script>
                </head><body><p>Abrindo <a href="%s">%s</a> no HQ-HUB...</p></body></html>
                """.formatted(esc(titulo), esc(descricao), esc(url), esc(titulo), esc(descricao), esc(url),
                esc(imagem), esc(imagem), esc(textoImagem), esc(titulo), esc(descricao), esc(imagem),
                "'" + destino + "'", esc(destino), esc(anuncio.tituloEdicao()));
    }

    private String imagemAbsoluta(String valor) {
        if (valor == null || valor.isBlank()) return null;
        try {
            URI uri = URI.create(valor.trim());
            if ("https".equalsIgnoreCase(uri.getScheme())) return uri.toString();
            if (uri.getScheme() == null && valor.startsWith("/")) return BASE + valor;
        } catch (IllegalArgumentException ignorado) {
            return null;
        }
        return null;
    }

    private boolean imagemExternaPermitida(String valor) {
        URI uri = URI.create(valor);
        String host = uri.getHost();
        return "https".equalsIgnoreCase(uri.getScheme()) && uri.getPort() == -1 && host != null
                && (host.equalsIgnoreCase("d14d9vp3wdof84.cloudfront.net")
                        || host.equalsIgnoreCase("res.cloudinary.com"));
    }

    private String modalidade(TipoAnuncio tipo) {
        return tipo == TipoAnuncio.VENDA ? "Venda" : tipo == TipoAnuncio.TROCA ? "Troca" : "Venda ou troca";
    }

    private String moeda(BigDecimal valor) {
        return NumberFormat.getCurrencyInstance(Locale.forLanguageTag("pt-BR")).format(valor);
    }

    private String esc(String texto) {
        return texto == null ? "" : texto.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
}
