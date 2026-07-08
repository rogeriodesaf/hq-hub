package br.com.hqhub.resource;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.List;

import org.eclipse.microprofile.config.inject.ConfigProperty;

import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.ImagemPostagemFeed;
import br.com.hqhub.entity.ItemColecao;
import br.com.hqhub.entity.PostagemFeed;
import br.com.hqhub.entity.Serie;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.ImagemPostagemFeedRepository;
import br.com.hqhub.repository.ItemColecaoRepository;
import br.com.hqhub.repository.PostagemFeedRepository;
import br.com.hqhub.service.UrlPublicaService;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/compartilhar")
public class CompartilhamentoResource {

    private static final String IMAGEM_PADRAO = "/assets/logo-hqhub.png";

    private final PostagemFeedRepository postagemRepository;
    private final ImagemPostagemFeedRepository imagemRepository;
    private final ItemColecaoRepository itemColecaoRepository;
    private final EdicaoRepository edicaoRepository;
    private final UrlPublicaService urlPublicaService;
    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(8))
            .followRedirects(HttpClient.Redirect.NORMAL)
            .build();

    @ConfigProperty(name = "hqhub.url-base", defaultValue = "https://hqhub-frontend.onrender.com")
    String urlBase;

    public CompartilhamentoResource(
            PostagemFeedRepository postagemRepository,
            ImagemPostagemFeedRepository imagemRepository,
            ItemColecaoRepository itemColecaoRepository,
            EdicaoRepository edicaoRepository,
            UrlPublicaService urlPublicaService) {
        this.postagemRepository = postagemRepository;
        this.imagemRepository = imagemRepository;
        this.itemColecaoRepository = itemColecaoRepository;
        this.edicaoRepository = edicaoRepository;
        this.urlPublicaService = urlPublicaService;
    }

    @GET
    @Path("/postagens/{id}")
    @Produces(MediaType.TEXT_HTML)
    @Transactional
    public Response compartilharPostagem(@PathParam("id") Long id) {
        return postagemRepository.findByIdOptional(id)
                .map(postagem -> Response.ok(htmlPostagem(postagem)).build())
                .orElseGet(() -> Response.status(Response.Status.NOT_FOUND)
                        .entity(htmlNaoEncontrado())
                        .type(MediaType.TEXT_HTML)
                        .build());
    }

    @GET
    @Path("/postagens/{id}/imagem")
    @Produces({ "image/jpeg", "image/png", "image/webp", "image/gif" })
    @Transactional
    public Response imagemPostagem(@PathParam("id") Long id) {
        return postagemRepository.findByIdOptional(id)
                .map(this::responderImagem)
                .orElseGet(() -> Response.status(Response.Status.NOT_FOUND).build());
    }

    private String htmlPostagem(PostagemFeed postagem) {
        String appUrl = appUrl(postagem);
        String titulo = titulo(postagem);
        String descricao = descricao(postagem);
        String imagem = imagemCompartilhamento(postagem);
        String urlCompartilhamento = baseNormalizada() + "/api/compartilhar/postagens/" + postagem.getId();

        return """
                <!doctype html>
                <html lang="pt-BR">
                <head>
                  <meta charset="utf-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1">
                  <title>%s</title>
                  <meta name="description" content="%s">
                  <meta property="og:type" content="article">
                  <meta property="og:site_name" content="HQ-HUB">
                  <meta property="og:title" content="%s">
                  <meta property="og:description" content="%s">
                  <meta property="og:image" content="%s">
                  <meta property="og:image:secure_url" content="%s">
                  <meta property="og:image:width" content="1200">
                  <meta property="og:image:height" content="630">
                  <meta property="og:url" content="%s">
                  <meta name="twitter:card" content="summary_large_image">
                  <meta name="twitter:title" content="%s">
                  <meta name="twitter:description" content="%s">
                  <meta name="twitter:image" content="%s">
                  <link rel="canonical" href="%s">
                </head>
                <body>
                  <main>
                    <h1>%s</h1>
                    <p>%s</p>
                    <p><a href="%s">Abrir no HQ-HUB</a></p>
                  </main>
                  <script>window.location.replace(%s);</script>
                </body>
                </html>
                """.formatted(
                escaparHtml(titulo),
                escaparHtml(descricao),
                escaparHtml(titulo),
                escaparHtml(descricao),
                escaparHtml(imagem),
                escaparHtml(imagem),
                escaparHtml(urlCompartilhamento),
                escaparHtml(titulo),
                escaparHtml(descricao),
                escaparHtml(imagem),
                escaparHtml(appUrl),
                escaparHtml(titulo),
                escaparHtml(descricao),
                escaparHtml(appUrl),
                literalJavascript(appUrl));
    }

    private Response responderImagem(PostagemFeed postagem) {
        String urlImagem = imagem(postagem);
        try {
            HttpRequest request = HttpRequest.newBuilder(URI.create(urlImagem))
                    .timeout(Duration.ofSeconds(12))
                    .header("User-Agent", "HQ-HUB/1.0 image-preview")
                    .GET()
                    .build();
            HttpResponse<byte[]> resposta = httpClient.send(request, HttpResponse.BodyHandlers.ofByteArray());
            if (resposta.statusCode() >= 200 && resposta.statusCode() < 300 && resposta.body().length > 0) {
                String tipo = resposta.headers().firstValue("content-type")
                        .filter(valor -> valor.toLowerCase().startsWith("image/"))
                        .orElse(MediaType.APPLICATION_OCTET_STREAM);
                return Response.ok(resposta.body(), tipo)
                        .header("Cache-Control", "public, max-age=86400")
                        .build();
            }
        } catch (Exception ignored) {
            // Fallback abaixo evita quebrar o preview quando a origem externa bloqueia a imagem.
        }

        return Response.temporaryRedirect(URI.create(urlAbsoluta(IMAGEM_PADRAO))).build();
    }

    private String htmlNaoEncontrado() {
        String appUrl = baseNormalizada() + "/painel";
        return """
                <!doctype html>
                <html lang="pt-BR">
                <head>
                  <meta charset="utf-8">
                  <title>Postagem nao encontrada - HQ-HUB</title>
                  <meta property="og:title" content="Postagem nao encontrada - HQ-HUB">
                  <meta property="og:description" content="Essa postagem nao esta mais disponivel.">
                  <meta property="og:image" content="%s">
                </head>
                <body>
                  <p>Essa postagem nao esta mais disponivel.</p>
                  <p><a href="%s">Abrir HQ-HUB</a></p>
                </body>
                </html>
                """.formatted(escaparHtml(urlAbsoluta(IMAGEM_PADRAO)), escaparHtml(appUrl));
    }

    private String titulo(PostagemFeed postagem) {
        String autor = postagem.getUsuario().getNome();
        if (postagem.getItemColecao() != null) {
            return autor + " adicionou " + tituloColecao(postagem.getItemColecao()) + " a colecao";
        }
        if (postagem.getSerieCatalogo() != null) {
            return autor + " atualizou " + postagem.getSerieCatalogo().getTitulo() + " no catalogo";
        }
        return "Postagem de " + autor + " no HQ-HUB";
    }

    private String descricao(PostagemFeed postagem) {
        if (postagem.getItemColecao() != null) {
            ItemColecao item = postagem.getItemColecao();
            Serie serie = item.getEdicao().getSerie();
            long quantidade = itemColecaoRepository.contarPorUsuarioESerie(item.getUsuario().getId(), serie.getId());
            return "%d edicao(oes) - %s".formatted(quantidade, serie.getEditora().getNome());
        }
        if (postagem.getSerieCatalogo() != null) {
            Serie serie = postagem.getSerieCatalogo();
            long quantidade = edicaoRepository.contarPorSerie(serie.getId());
            return "%d edicao(oes) - %s".formatted(quantidade, serie.getEditora().getNome());
        }
        return resumir(postagem.getConteudo(), 180);
    }

    private String imagem(PostagemFeed postagem) {
        if (postagem.getItemColecao() != null) {
            return primeiraUrlPublica(postagem.getItemColecao().getEdicao().getUrlCapa(), postagem.getUrlImagem());
        }
        if (postagem.getSerieCatalogo() != null) {
            return edicaoRepository.primeiraCapaPorSerie(postagem.getSerieCatalogo().getId())
                    .map(this::urlPublica)
                    .orElseGet(() -> urlPublica(postagem.getUrlImagem(), urlAbsoluta(IMAGEM_PADRAO)));
        }
        List<ImagemPostagemFeed> imagens = imagemRepository.listarPorPostagem(postagem.getId());
        if (!imagens.isEmpty()) {
            return urlPublica(imagens.get(0).getUrlImagem());
        }
        return urlPublica(postagem.getUrlImagem(), urlAbsoluta(IMAGEM_PADRAO));
    }

    private String imagemCompartilhamento(PostagemFeed postagem) {
        return baseNormalizada() + "/api/compartilhar/postagens/" + postagem.getId() + "/imagem?v=" + versao(postagem);
    }

    private String primeiraUrlPublica(String... urls) {
        for (String url : urls) {
            if (url != null && !url.isBlank()) {
                return urlPublica(url);
            }
        }
        return urlAbsoluta(IMAGEM_PADRAO);
    }

    private String tituloColecao(ItemColecao item) {
        Edicao edicao = item.getEdicao();
        String tituloSerie = edicao.getSerie().getTitulo();
        return tituloSerie == null || tituloSerie.isBlank() ? "uma HQ" : tituloSerie;
    }

    private String appUrl(PostagemFeed postagem) {
        return baseNormalizada() + "/usuario/" + postagem.getUsuario().getId() + "#postagem-" + postagem.getId();
    }

    private String versao(PostagemFeed postagem) {
        return postagem.getDataAtualizacao() == null
                ? String.valueOf(postagem.getId())
                : String.valueOf(postagem.getDataAtualizacao().toString().hashCode());
    }

    private String urlPublica(String url) {
        return urlPublica(url, urlAbsoluta(IMAGEM_PADRAO));
    }

    private String urlPublica(String url, String fallback) {
        if (url == null || url.isBlank()) {
            return fallback;
        }
        String normalizada = urlPublicaService.normalizarApiUrl(url);
        return urlAbsoluta(normalizada);
    }

    private String urlAbsoluta(String url) {
        if (url == null || url.isBlank()) {
            return baseNormalizada() + IMAGEM_PADRAO;
        }
        if (url.startsWith("http://") || url.startsWith("https://")) {
            return url;
        }
        return baseNormalizada() + (url.startsWith("/") ? url : "/" + url);
    }

    private String baseNormalizada() {
        String base = urlBase == null || urlBase.isBlank() ? "https://hqhub-frontend.onrender.com" : urlBase.trim();
        return base.endsWith("/") ? base.substring(0, base.length() - 1) : base;
    }

    private String resumir(String texto, int limite) {
        if (texto == null || texto.isBlank()) {
            return "Veja essa postagem no HQ-HUB.";
        }
        String limpo = texto.trim().replaceAll("\\s+", " ");
        return limpo.length() <= limite ? limpo : limpo.substring(0, limite - 1) + "...";
    }

    private String escaparHtml(String texto) {
        return texto == null ? "" : texto
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String literalJavascript(String texto) {
        String valor = texto == null ? "" : texto
                .replace("\\", "\\\\")
                .replace("'", "\\'")
                .replace("\r", "")
                .replace("\n", "\\n");
        return "'" + valor + "'";
    }
}
