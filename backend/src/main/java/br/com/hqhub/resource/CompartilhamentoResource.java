package br.com.hqhub.resource;

import java.awt.AlphaComposite;
import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.imageio.ImageIO;

import org.eclipse.microprofile.config.inject.ConfigProperty;

import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.ImagemPostagemFeed;
import br.com.hqhub.entity.ItemColecao;
import br.com.hqhub.entity.PostagemFeed;
import br.com.hqhub.entity.Serie;
import br.com.hqhub.entity.VideoRelacionadoFeed;
import br.com.hqhub.dto.PostagemColecaoPublicaDTO;
import br.com.hqhub.dto.DetalheCatalogoPublicoDTO;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.ImagemPostagemFeedRepository;
import br.com.hqhub.repository.ItemColecaoRepository;
import br.com.hqhub.repository.PostagemFeedRepository;
import br.com.hqhub.repository.VideoRelacionadoFeedRepository;
import br.com.hqhub.service.UrlPublicaService;
import br.com.hqhub.service.FeedSocialService;
import br.com.hqhub.service.EdicaoService;
import br.com.hqhub.service.LinkEdicaoService;
import br.com.hqhub.service.HistoriaService;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.HeaderParam;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.UriInfo;
import jakarta.ws.rs.core.Context;

@Path("/compartilhar")
public class CompartilhamentoResource {

    private static final String IMAGEM_PADRAO = "/assets/logo-hqhub.png";
    private static final int LARGURA_IMAGEM_SOCIAL = 1200;
    private static final int ALTURA_IMAGEM_SOCIAL = 630;
    private static final Pattern YOUTUBE_ID_CAMINHO = Pattern.compile(
            "(?:youtu\\.be/|youtube\\.com/(?:shorts|live|embed)/)([A-Za-z0-9_-]{6,})",
            Pattern.CASE_INSENSITIVE);
    private static final Pattern YOUTUBE_ID_QUERY = Pattern.compile("[?&]v=([A-Za-z0-9_-]{6,})", Pattern.CASE_INSENSITIVE);
    private static final int LIMITE_TITULO_COMPARTILHAMENTO = 90;

    private final PostagemFeedRepository postagemRepository;
    private final ImagemPostagemFeedRepository imagemRepository;
    private final VideoRelacionadoFeedRepository videoRelacionadoRepository;
    private final EdicaoRepository edicaoRepository;
    private final ItemColecaoRepository itemColecaoRepository;
    private final UrlPublicaService urlPublicaService;
    private final FeedSocialService feedSocialService;
    private final EdicaoService edicaoService;
    private final LinkEdicaoService linkEdicaoService;
    private final HistoriaService historiaService;
    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(8))
            .followRedirects(HttpClient.Redirect.NORMAL)
            .build();
    @ConfigProperty(name = "hqhub.url-base", defaultValue = "https://hqhub-frontend.onrender.com")
    String urlBase;

    @ConfigProperty(name = "hqhub.api-url-publica", defaultValue = "https://hqhub-backend.onrender.com")
    String apiUrlPublica;

    @ConfigProperty(name = "hqhub.url-compartilhamento", defaultValue = "https://hqhub-backend.onrender.com/api/compartilhar")
    String urlCompartilhamentoPublica;

    @ConfigProperty(name = "hqhub.compartilhamento.abrir-catalogo", defaultValue = "false")
    boolean abrirCatalogoAoCompartilhar;

    public CompartilhamentoResource(
            PostagemFeedRepository postagemRepository,
            ImagemPostagemFeedRepository imagemRepository,
            VideoRelacionadoFeedRepository videoRelacionadoRepository,
            EdicaoRepository edicaoRepository,
            ItemColecaoRepository itemColecaoRepository,
            UrlPublicaService urlPublicaService,
            FeedSocialService feedSocialService,
            EdicaoService edicaoService,
            LinkEdicaoService linkEdicaoService,
            HistoriaService historiaService) {
        this.postagemRepository = postagemRepository;
        this.imagemRepository = imagemRepository;
        this.videoRelacionadoRepository = videoRelacionadoRepository;
        this.edicaoRepository = edicaoRepository;
        this.itemColecaoRepository = itemColecaoRepository;
        this.urlPublicaService = urlPublicaService;
        this.feedSocialService = feedSocialService;
        this.edicaoService = edicaoService;
        this.linkEdicaoService = linkEdicaoService;
        this.historiaService = historiaService;
    }

    @GET
    @Path("/postagens/{id}/dados")
    @Produces(MediaType.APPLICATION_JSON)
    public Response obterPostagemPublica(@PathParam("id") Long id) {
        return Response.ok(feedSocialService.obterPostagemPublica(id)).build();
    }

    @GET
    @Path("/catalogo/edicoes/{id}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response obterDetalheCatalogoPublico(@PathParam("id") Long id) {
        return Response.ok(new DetalheCatalogoPublicoDTO(
                edicaoService.buscarPorId(id),
                linkEdicaoService.listarPorEdicao(id),
                historiaService.listarConteudosPorEdicao(id),
                historiaService.listarPublicacoesPorEdicaoPublicada(id),
                historiaService.listarPublicacoesPorEdicaoOriginal(id))).build();
    }

    @GET
    @Path("/postagens/{id}")
    @Produces(MediaType.TEXT_HTML)
    @Transactional
    public Response compartilharPostagem(
            @PathParam("id") Long id,
            @Context UriInfo uriInfo,
            @HeaderParam("X-Forwarded-Proto") String protocoloEncaminhado) {
        return postagemRepository.findByIdOptional(id)
                .map(postagem -> Response.ok(
                        htmlPostagem(postagem, origemRequisicao(uriInfo, protocoloEncaminhado))).build())
                .orElseGet(() -> Response.status(Response.Status.NOT_FOUND)
                        .entity(htmlNaoEncontrado())
                        .type(MediaType.TEXT_HTML)
                        .build());
    }

    @GET
    @Path("/postagens/{id}/v13")
    @Produces(MediaType.TEXT_HTML)
    @Transactional
    public Response compartilharPostagemV13(
            @PathParam("id") Long id,
            @Context UriInfo uriInfo,
            @HeaderParam("X-Forwarded-Proto") String protocoloEncaminhado) {
        return compartilharPostagem(id, uriInfo, protocoloEncaminhado);
    }

    @GET
    @Path("/postagens/{id}/v14")
    @Produces(MediaType.TEXT_HTML)
    @Transactional
    public Response compartilharPostagemV14(
            @PathParam("id") Long id,
            @Context UriInfo uriInfo,
            @HeaderParam("X-Forwarded-Proto") String protocoloEncaminhado) {
        return compartilharPostagem(id, uriInfo, protocoloEncaminhado);
    }

    @GET
    @Path("/postagens/{id}/v15")
    @Produces(MediaType.TEXT_HTML)
    @Transactional
    public Response compartilharPostagemV15(
            @PathParam("id") Long id,
            @QueryParam("contexto") String contexto,
            @Context UriInfo uriInfo,
            @HeaderParam("X-Forwarded-Proto") String protocoloEncaminhado) {
        return postagemRepository.findByIdOptional(id)
                .map(postagem -> Response.ok(htmlPostagem(
                        postagem,
                        origemRequisicao(uriInfo, protocoloEncaminhado),
                        ContextoCompartilhamento.de(contexto, postagem),
                        true)).build())
                .orElseGet(() -> Response.status(Response.Status.NOT_FOUND)
                        .entity(htmlNaoEncontrado())
                        .type(MediaType.TEXT_HTML)
                        .build());
    }

    @GET
    @Path("/postagens/{id}/v16")
    @Produces(MediaType.TEXT_HTML)
    @Transactional
    public Response compartilharPostagemV16(
            @PathParam("id") Long id,
            @QueryParam("contexto") String contexto,
            @Context UriInfo uriInfo,
            @HeaderParam("X-Forwarded-Proto") String protocoloEncaminhado) {
        return compartilharPostagemV15(id, contexto, uriInfo, protocoloEncaminhado);
    }

    @GET
    @Path("/hq/{id}")
    @Produces(MediaType.TEXT_HTML)
    @Transactional
    public Response compartilharHq(@PathParam("id") Long id) {
        return postagemRepository.findByIdOptional(id)
                .map(postagem -> Response.ok(htmlHqPublica(postagem)).build())
                .orElseGet(() -> Response.status(Response.Status.NOT_FOUND)
                        .entity(htmlNaoEncontrado())
                        .type(MediaType.TEXT_HTML)
                        .build());
    }

    @GET
    @Path("/hq/{id}/imagem.jpg")
    @Produces("image/jpeg")
    @Transactional
    public Response imagemHq(@PathParam("id") Long id) {
        return postagemRepository.findByIdOptional(id)
                .map(postagem -> responderImagem(postagem, ContextoCompartilhamento.de(null, postagem)))
                .orElseGet(() -> Response.status(Response.Status.NOT_FOUND).build());
    }

    @GET
    @Path("/postagens/{id}/imagem")
    @Produces("image/jpeg")
    @Transactional
    public Response imagemPostagem(@PathParam("id") Long id) {
        return buscarImagemPostagem(id);
    }

    @GET
    @Path("/postagens/{id}/imagem.jpg")
    @Produces("image/jpeg")
    @Transactional
    public Response imagemPostagemJpeg(@PathParam("id") Long id) {
        return buscarImagemPostagem(id);
    }

    @GET
    @Path("/postagens/{id}/imagem-v10.jpg")
    @Produces("image/jpeg")
    @Transactional
    public Response imagemPostagemJpegV10(@PathParam("id") Long id) {
        return buscarImagemPostagem(id);
    }

    @GET
    @Path("/postagens/{id}/imagem-v14.jpg")
    @Produces("image/jpeg")
    @Transactional
    public Response imagemPostagemJpegV14(@PathParam("id") Long id) {
        return buscarImagemPostagem(id);
    }

    @GET
    @Path("/postagens/{id}/imagem-v15.jpg")
    @Produces("image/jpeg")
    @Transactional
    public Response imagemPostagemJpegV15(
            @PathParam("id") Long id,
            @QueryParam("contexto") String contexto) {
        return postagemRepository.findByIdOptional(id)
                .map(postagem -> responderImagem(postagem, ContextoCompartilhamento.de(contexto, postagem)))
                .orElseGet(() -> Response.status(Response.Status.NOT_FOUND).build());
    }

    @GET
    @Path("/postagens/{id}/imagem-v16.jpg")
    @Produces("image/jpeg")
    @Transactional
    public Response imagemPostagemJpegV16(
            @PathParam("id") Long id,
            @QueryParam("contexto") String contexto) {
        return imagemPostagemJpegV15(id, contexto);
    }

    @GET
    @Path("/postagens/{id}/colecao")
    @Produces(MediaType.APPLICATION_JSON)
    @Transactional
    public Response obterColecaoPublica(@PathParam("id") Long id) {
        PostagemFeed postagem = postagemRepository.findByIdOptional(id)
                .filter(item -> item.getItemColecao() != null)
                .orElse(null);
        if (postagem == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        ItemColecao destaque = postagem.getItemColecao();
        Serie serie = destaque.getEdicao().getSerie();
        Long usuarioId = postagem.getUsuario().getId();
        List<PostagemColecaoPublicaDTO.Edicao> edicoes = itemColecaoRepository
                .listarPorUsuarioESerie(usuarioId, serie.getId())
                .stream()
                .map(item -> new PostagemColecaoPublicaDTO.Edicao(
                        item.getEdicao().getId(),
                        item.getEdicao().getNumero(),
                        item.getEdicao().getTitulo(),
                        edicaoRepository.capaPublicaPorEdicao(item.getEdicao().getId())
                                .map(urlPublicaService::normalizarApiUrl)
                                .orElse(null),
                        item.getStatusLeitura()))
                .toList();

        return Response.ok(new PostagemColecaoPublicaDTO(
                postagem.getId(),
                usuarioId,
                postagem.getUsuario().getNome(),
                postagem.getConteudo(),
                serie.getTitulo(),
                serie.getEditora().getNome(),
                edicoes)).build();
    }

    private Response buscarImagemPostagem(Long id) {
        return postagemRepository.findByIdOptional(id)
                .map(postagem -> responderImagem(postagem, ContextoCompartilhamento.de(null, postagem)))
                .orElseGet(() -> Response.status(Response.Status.NOT_FOUND).build());
    }

    private String htmlPostagem(PostagemFeed postagem, String origemCompartilhamento) {
        return htmlPostagem(
                postagem,
                origemCompartilhamento,
                ContextoCompartilhamento.de(null, postagem),
                false);
    }

    private String htmlPostagem(
            PostagemFeed postagem,
            String origemCompartilhamento,
            ContextoCompartilhamento contexto,
            boolean urlAmigavel) {
        String appUrl = urlAmigavel ? appUrlCatalogo(postagem) : appUrl(postagem);
        VideoRelacionadoFeed primeiroVideo = primeiroVideo(postagem.getId());
        ApresentacaoCompartilhamento apresentacao = apresentacao(postagem, primeiroVideo, contexto);
        String titulo = apresentacao.titulo();
        String descricao = apresentacao.descricao();
        String imagem = urlAmigavel
                ? imagemCompartilhamento(postagem, contexto, true)
                : imagemCompartilhamento(postagem, origemCompartilhamento);
        String urlCompartilhamento = urlAmigavel
                ? urlCompartilhamentoAmigavel(postagem, contexto)
                : urlCompartilhamento(postagem, origemCompartilhamento);

        return """
                <!doctype html>
                <html lang="pt-BR">
                <head>
                  <meta charset="utf-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1">
                  <title>%s</title>
                  <link rel="canonical" href="%s">
                  <meta name="description" content="%s">
                  <meta property="og:type" content="website">
                  <meta property="og:locale" content="pt_BR">
                  <meta property="og:site_name" content="HQ-HUB">
                  <meta property="og:url" content="%s">
                  <meta property="og:title" content="%s">
                  <meta property="og:description" content="%s">
                  <meta property="og:image" content="%s">
                  <meta property="og:image:secure_url" content="%s">
                  <meta property="og:image:type" content="image/jpeg">
                  <meta property="og:image:width" content="1200">
                  <meta property="og:image:height" content="630">
                  <meta property="og:image:alt" content="Capa de %s">
                  <meta name="twitter:card" content="summary_large_image">
                  <meta name="twitter:title" content="%s">
                  <meta name="twitter:description" content="%s">
                  <meta name="twitter:image" content="%s">
                  <meta name="twitter:image:alt" content="Capa de %s">
                  <script>window.location.replace(%s);</script>
                </head>
                <body>
                  <main>
                    <h1>%s</h1>
                    <p>%s</p>
                    <p><a href="%s">Abrir publicação no feed</a></p>
                  </main>
                </body>
                </html>
                """.formatted(
                escaparHtml(titulo),
                escaparHtml(urlCompartilhamento),
                escaparHtml(descricao),
                escaparHtml(urlCompartilhamento),
                escaparHtml(titulo),
                escaparHtml(descricao),
                escaparHtml(imagem),
                escaparHtml(imagem),
                escaparHtml(titulo),
                escaparHtml(titulo),
                escaparHtml(descricao),
                escaparHtml(imagem),
                escaparHtml(titulo),
                literalJavascript(appUrl),
                escaparHtml(titulo),
                escaparHtml("Redirecionando para o HQ-HUB..."),
                escaparHtml(appUrl));
    }

    private String htmlHqPublica(PostagemFeed postagem) {
        String titulo = limitarTexto(
                tituloCompartilhamento(postagem, primeiroVideo(postagem.getId())),
                LIMITE_TITULO_COMPARTILHAMENTO);
        String descricao = "Confira esta HQ no HQ-HUB";
        String urlPublica = urlHqPublica(postagem.getId());
        String imagem = origemApiNormalizada() + "/api/compartilhar/hq/" + postagem.getId() + "/imagem.jpg";
        String appUrl = appUrlPublica(postagem);

        return """
                <!doctype html>
                <html lang="pt-BR">
                <head>
                  <meta charset="utf-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1">
                  <title>%s</title>
                  <link rel="canonical" href="%s">
                  <meta name="description" content="%s">
                  <meta property="og:type" content="website">
                  <meta property="og:locale" content="pt_BR">
                  <meta property="og:site_name" content="HQ-HUB">
                  <meta property="og:url" content="%s">
                  <meta property="og:title" content="%s">
                  <meta property="og:description" content="%s">
                  <meta property="og:image" content="%s">
                  <meta property="og:image:secure_url" content="%s">
                  <meta property="og:image:type" content="image/jpeg">
                  <meta property="og:image:width" content="1200">
                  <meta property="og:image:height" content="630">
                  <meta property="og:image:alt" content="Capa de %s">
                  <meta name="twitter:card" content="summary_large_image">
                  <meta name="twitter:title" content="%s">
                  <meta name="twitter:description" content="%s">
                  <meta name="twitter:image" content="%s">
                  <script>window.location.replace(%s);</script>
                </head>
                <body>
                  <main>
                    <h1>%s</h1>
                    <p>%s</p>
                    <p><a href="%s">Abrir HQ no HQ-HUB</a></p>
                  </main>
                </body>
                </html>
                """.formatted(
                escaparHtml(titulo),
                escaparHtml(urlPublica),
                escaparHtml(descricao),
                escaparHtml(urlPublica),
                escaparHtml(titulo),
                escaparHtml(descricao),
                escaparHtml(imagem),
                escaparHtml(imagem),
                escaparHtml(titulo),
                escaparHtml(titulo),
                escaparHtml(descricao),
                escaparHtml(imagem),
                literalJavascript(appUrl),
                escaparHtml(titulo),
                escaparHtml(descricao),
                escaparHtml(appUrl));
    }

    private Response responderImagem(PostagemFeed postagem, ContextoCompartilhamento contexto) {
        String urlImagem = imagem(postagem);
        if (ehUrlGuia(urlImagem)) {
            urlImagem = urlAbsoluta(IMAGEM_PADRAO);
        }
        try {
            HttpRequest request = HttpRequest.newBuilder(URI.create(urlImagem))
                    .timeout(Duration.ofSeconds(12))
                    .header("User-Agent", "HQ-HUB/1.0 image-preview")
                    .GET()
                    .build();
            HttpResponse<byte[]> resposta = httpClient.send(request, HttpResponse.BodyHandlers.ofByteArray());
            if (resposta.statusCode() >= 200 && resposta.statusCode() < 300
                    && resposta.body().length > 0
                    && !ehUrlGuia(resposta.uri().toString())) {
                byte[] jpeg = criarImagemSocial(resposta.body());
                return Response.ok(jpeg, "image/jpeg")
                        .header("Cache-Control", "public, max-age=86400")
                        .header("Content-Length", jpeg.length)
                        .build();
            }
        } catch (Exception ignored) {
            // Fallback abaixo evita quebrar o preview quando a origem externa bloqueia a imagem.
        }

        return Response.temporaryRedirect(URI.create(urlAbsoluta(IMAGEM_PADRAO))).build();
    }

    private byte[] criarImagemSocial(byte[] conteudo) throws Exception {
        BufferedImage original;
        try (ByteArrayInputStream entrada = new ByteArrayInputStream(conteudo)) {
            original = ImageIO.read(entrada);
        }
        if (original == null) {
            throw new IllegalArgumentException("Formato de imagem não reconhecido.");
        }

        BufferedImage cartao = new BufferedImage(
                LARGURA_IMAGEM_SOCIAL,
                ALTURA_IMAGEM_SOCIAL,
                BufferedImage.TYPE_INT_RGB);
        Graphics2D grafico = cartao.createGraphics();
        try {
            grafico.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC);
            grafico.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
            desenharFundoDesfocado(grafico, original);
            grafico.setComposite(AlphaComposite.SrcOver);
            grafico.setColor(new Color(7, 12, 22, 72));
            grafico.fillRect(0, 0, LARGURA_IMAGEM_SOCIAL, ALTURA_IMAGEM_SOCIAL);

            int larguraMaxima = LARGURA_IMAGEM_SOCIAL;
            int alturaMaxima = ALTURA_IMAGEM_SOCIAL;
            double escala = Math.min(
                    (double) larguraMaxima / original.getWidth(),
                    (double) alturaMaxima / original.getHeight());
            int largura = Math.max(1, (int) Math.round(original.getWidth() * escala));
            int altura = Math.max(1, (int) Math.round(original.getHeight() * escala));
            int x = (LARGURA_IMAGEM_SOCIAL - largura) / 2;
            int y = (ALTURA_IMAGEM_SOCIAL - altura) / 2;

            grafico.drawImage(original, x, y, largura, altura, null);
            desenharLogoCompartilhamento(grafico);
            grafico.setColor(new Color(255, 135, 31));
            grafico.fillRect(0, ALTURA_IMAGEM_SOCIAL - 6, LARGURA_IMAGEM_SOCIAL, 6);
        } finally {
            grafico.dispose();
        }

        try (ByteArrayOutputStream saida = new ByteArrayOutputStream()) {
            if (!ImageIO.write(cartao, "jpg", saida)) {
                throw new IllegalStateException("Conversor JPEG indisponível.");
            }
            return saida.toByteArray();
        }
    }

    private void desenharLogoCompartilhamento(Graphics2D grafico) {
        String marca = "HQ-HUB";
        int largura = 112;
        int altura = 38;
        int margem = 14;
        int x = LARGURA_IMAGEM_SOCIAL - largura - margem;
        int y = ALTURA_IMAGEM_SOCIAL - altura - margem;

        grafico.setComposite(AlphaComposite.getInstance(AlphaComposite.SRC_OVER, 0.82f));
        grafico.setColor(new Color(7, 12, 22));
        grafico.fillRoundRect(x, y, largura, altura, 14, 14);
        grafico.setColor(new Color(255, 135, 31));
        grafico.setFont(new java.awt.Font(java.awt.Font.SANS_SERIF, java.awt.Font.BOLD, 20));
        java.awt.FontMetrics metricas = grafico.getFontMetrics();
        int textoX = x + (largura - metricas.stringWidth(marca)) / 2;
        int textoY = y + (altura - metricas.getHeight()) / 2 + metricas.getAscent();
        grafico.drawString(marca, textoX, textoY);
        grafico.setComposite(AlphaComposite.SrcOver);
    }

    private void desenharFundoDesfocado(Graphics2D grafico, BufferedImage original) {
        int larguraMiniatura = 36;
        int alturaMiniatura = 19;
        BufferedImage miniatura = new BufferedImage(
                larguraMiniatura,
                alturaMiniatura,
                BufferedImage.TYPE_INT_RGB);
        Graphics2D reduzido = miniatura.createGraphics();
        try {
            reduzido.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
            desenharImagemCobrindo(reduzido, original, larguraMiniatura, alturaMiniatura, 1f);
        } finally {
            reduzido.dispose();
        }
        grafico.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC);
        grafico.setComposite(AlphaComposite.SrcOver);
        grafico.drawImage(miniatura, 0, 0, LARGURA_IMAGEM_SOCIAL, ALTURA_IMAGEM_SOCIAL, null);
    }

    private void desenharImagemCobrindo(
            Graphics2D grafico,
            BufferedImage original,
            int larguraDestino,
            int alturaDestino,
            float opacidade) {
        double escala = Math.max(
                (double) larguraDestino / original.getWidth(),
                (double) alturaDestino / original.getHeight());
        int largura = Math.max(1, (int) Math.round(original.getWidth() * escala));
        int altura = Math.max(1, (int) Math.round(original.getHeight() * escala));
        int x = (larguraDestino - largura) / 2;
        int y = (alturaDestino - altura) / 2;

        grafico.setComposite(AlphaComposite.getInstance(AlphaComposite.SRC_OVER, opacidade));
        grafico.drawImage(original, x, y, largura, altura, null);
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

    private String tituloHq(PostagemFeed postagem) {
        if (postagem.getItemColecao() != null) {
            ItemColecao item = postagem.getItemColecao();
            return tituloEdicao(item.getEdicao());
        }
        if (postagem.getSerieCatalogo() != null) {
            String titulo = postagem.getSerieCatalogo().getTitulo();
            return titulo == null || titulo.isBlank() ? "HQ-HUB" : titulo;
        }
        return "HQ-HUB";
    }

    private String tituloEdicao(Edicao edicao) {
        if (edicao == null || edicao.getSerie() == null) {
            return "HQ-HUB";
        }
        String tituloSerie = edicao.getSerie().getTitulo();
        String numero = edicao.getNumero();
        if (tituloSerie == null || tituloSerie.isBlank()) {
            return numero == null || numero.isBlank() ? "HQ-HUB" : "Edição " + numero;
        }
        return numero == null || numero.isBlank() ? tituloSerie : tituloSerie + " #" + numero;
    }

    private String tituloCompartilhamento(PostagemFeed postagem, VideoRelacionadoFeed video) {
        String tituloHq = tituloHq(postagem);
        if (!"HQ-HUB".equals(tituloHq)) {
            return tituloHq;
        }
        if (video != null && video.getTitulo() != null && !video.getTitulo().isBlank()
                && !"Vídeo compartilhado no YouTube".equalsIgnoreCase(video.getTitulo().trim())) {
            return limitarTexto(video.getTitulo().trim(), LIMITE_TITULO_COMPARTILHAMENTO);
        }
        String nome = nomeAutor(postagem, "Um leitor");
        String titulo = video == null ? nome + " no HQ-HUB" : nome + " compartilhou um vídeo no HQ-HUB";
        return limitarTexto(titulo, LIMITE_TITULO_COMPARTILHAMENTO);
    }

    private String imagem(PostagemFeed postagem) {
        if (postagem.getItemColecao() != null) {
            String capa = edicaoRepository.capaPublicaPorEdicao(postagem.getItemColecao().getEdicao().getId())
                    .map(this::urlPublica)
                    .orElseGet(() -> urlPublicaSegura(postagem.getUrlImagem()));
            if (!capa.equals(urlAbsoluta(IMAGEM_PADRAO))) {
                return capa;
            }
        }
        if (postagem.getSerieCatalogo() != null) {
            String capaDoJson = urlPublicaSegura(postagem.getUrlImagem());
            if (!capaDoJson.equals(urlAbsoluta(IMAGEM_PADRAO))) {
                return capaDoJson;
            }
            String capa = edicaoRepository.primeiraCapaPorSerie(postagem.getSerieCatalogo().getId())
                    .map(this::urlPublica)
                    .orElse(capaDoJson);
            if (!capa.equals(urlAbsoluta(IMAGEM_PADRAO))) {
                return capa;
            }
        }
        String thumbnailVideo = thumbnailPrimeiroVideo(postagem.getId());
        if (thumbnailVideo != null) {
            return urlPublica(thumbnailVideo);
        }
        List<ImagemPostagemFeed> imagens = imagemRepository.listarPorPostagem(postagem.getId());
        if (!imagens.isEmpty()) {
            return urlPublica(imagens.get(0).getUrlImagem());
        }
        return urlPublica(postagem.getUrlImagem(), urlAbsoluta(IMAGEM_PADRAO));
    }

    private ApresentacaoCompartilhamento apresentacao(
            PostagemFeed postagem,
            VideoRelacionadoFeed video,
            ContextoCompartilhamento contexto) {
        String titulo = limitarTexto(tituloCompartilhamento(postagem, video), LIMITE_TITULO_COMPARTILHAMENTO);
        String detalhe = detalheEditorial(postagem);
        String descricao = contexto.descricao(detalhe);
        return new ApresentacaoCompartilhamento(titulo, descricao, detalhe, contexto);
    }

    private String detalheEditorial(PostagemFeed postagem) {
        Serie serie = null;
        if (postagem.getItemColecao() != null && postagem.getItemColecao().getEdicao() != null) {
            serie = postagem.getItemColecao().getEdicao().getSerie();
        } else if (postagem.getSerieCatalogo() != null) {
            serie = postagem.getSerieCatalogo();
        }
        if (serie == null) {
            return "Disponível no HQ-HUB";
        }
        String editora = serie.getEditora() == null ? null : serie.getEditora().getNome();
        String volume = serie.getVolume() == null ? null : "Volume " + serie.getVolume();
        if (editora != null && !editora.isBlank() && volume != null) {
            return editora + " · " + volume;
        }
        if (editora != null && !editora.isBlank()) {
            return editora;
        }
        return volume == null ? "Disponível no HQ-HUB" : volume;
    }

    private String urlPublicaSegura(String url) {
        if (ehUrlGuia(url)) {
            return urlAbsoluta(IMAGEM_PADRAO);
        }
        return urlPublica(url, urlAbsoluta(IMAGEM_PADRAO));
    }

    private String imagemCompartilhamento(PostagemFeed postagem, String origemCompartilhamento) {
        return origemCompartilhamento + "/api/compartilhar/postagens/" + postagem.getId()
                + "/imagem-v14.jpg?v=" + versao(postagem);
    }

    private String imagemCompartilhamento(
            PostagemFeed postagem,
            ContextoCompartilhamento contexto,
            boolean urlAmigavel) {
        if (!urlAmigavel) {
            return imagemCompartilhamento(postagem, origemApiNormalizada());
        }
        return origemApiNormalizada() + "/api/compartilhar/postagens/" + postagem.getId()
                + "/imagem-v16.jpg?contexto=" + contexto.parametro()
                + "&v=" + versao(postagem);
    }

    private String urlCompartilhamento(PostagemFeed postagem, String origemCompartilhamento) {
        return origemCompartilhamento + "/api/compartilhar/postagens/" + postagem.getId()
                + "/v14?v=" + versao(postagem);
    }

    private String thumbnailPrimeiroVideo(Long postagemId) {
        VideoRelacionadoFeed video = primeiroVideo(postagemId);
        if (video == null) {
            return null;
        }
        String thumbnail = thumbnailVideo(video);
        return thumbnail == null || thumbnail.isBlank() ? null : thumbnail;
    }

    private VideoRelacionadoFeed primeiroVideo(Long postagemId) {
        return videoRelacionadoRepository.listarPorPostagem(postagemId).stream()
                .findFirst()
                .orElse(null);
    }

    private String thumbnailVideo(VideoRelacionadoFeed video) {
        if (video.getThumbnail() != null && !video.getThumbnail().isBlank()) {
            return video.getThumbnail().trim();
        }
        String videoId = extrairIdYoutube(video.getUrl());
        return videoId == null ? null : "https://i.ytimg.com/vi/" + videoId + "/hqdefault.jpg";
    }

    private String extrairIdYoutube(String url) {
        if (url == null || url.isBlank()) {
            return null;
        }
        Matcher caminho = YOUTUBE_ID_CAMINHO.matcher(url);
        if (caminho.find()) {
            return caminho.group(1);
        }
        Matcher query = YOUTUBE_ID_QUERY.matcher(url);
        return query.find() ? query.group(1) : null;
    }

    private String nomeAutor(PostagemFeed postagem, String fallback) {
        if (postagem.getUsuario() == null || postagem.getUsuario().getNome() == null
                || postagem.getUsuario().getNome().isBlank()) {
            return fallback;
        }
        return postagem.getUsuario().getNome().trim();
    }

    private String limitarTexto(String texto, int limite) {
        if (texto == null || texto.length() <= limite) {
            return texto;
        }
        int corte = texto.lastIndexOf(' ', limite - 1);
        if (corte < limite / 2) {
            corte = limite - 1;
        }
        return texto.substring(0, corte).stripTrailing() + "…";
    }

    private String appUrl(PostagemFeed postagem) {
        if (!abrirCatalogoAoCompartilhar) {
            return baseNormalizada() + "/postagem/" + postagem.getId();
        }

        return appUrlCatalogo(postagem);
    }

    private String appUrlCatalogo(PostagemFeed postagem) {
        Long edicaoId = null;
        if (postagem.getItemColecao() != null) {
            edicaoId = postagem.getItemColecao().getEdicao().getId();
        } else if (postagem.getSerieCatalogo() != null) {
            edicaoId = edicaoRepository.primeiraEdicaoPorSerie(postagem.getSerieCatalogo().getId())
                    .map(Edicao::getId)
                    .orElse(null);
        }
        if (edicaoId != null) {
            return baseNormalizada() + "/catalogo?edicaoId=" + edicaoId;
        }
        return baseNormalizada() + "/postagem/" + postagem.getId();
    }

    private String appUrlPublica(PostagemFeed postagem) {
        Long edicaoId = null;
        if (postagem.getItemColecao() != null) {
            edicaoId = postagem.getItemColecao().getEdicao().getId();
        } else if (postagem.getSerieCatalogo() != null) {
            edicaoId = edicaoRepository.primeiraEdicaoPorSerie(postagem.getSerieCatalogo().getId())
                    .map(Edicao::getId)
                    .orElse(null);
        }
        if (edicaoId != null) {
            return baseNormalizada() + "/catalogo?edicaoId=" + edicaoId;
        }
        return baseNormalizada() + "/postagem/" + postagem.getId();
    }

    private String urlHqPublica(Long postagemId) {
        return origemCompartilhamentoNormalizada() + "/hq/" + postagemId;
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
        if (ehUrlGuia(url)) {
            return fallback;
        }
        String normalizada = urlPublicaService.normalizarApiUrl(url);
        return urlAbsoluta(normalizada);
    }

    private String urlCompartilhamentoAmigavel(
            PostagemFeed postagem,
            ContextoCompartilhamento contexto) {
        return baseNormalizada() + "/compartilhar/hq/postagem/" + postagem.getId()
                + "?contexto=" + contexto.parametro()
                + "&v=" + versao(postagem);
    }

    private boolean ehUrlGuia(String url) {
        if (url == null || url.isBlank()) {
            return false;
        }
        String normalizada = url.toLowerCase(java.util.Locale.ROOT);
        try {
            normalizada = java.net.URLDecoder.decode(normalizada, java.nio.charset.StandardCharsets.UTF_8);
        } catch (IllegalArgumentException ignored) {
            // Uma URL malformada continua sendo avaliada em sua forma original.
        }
        return normalizada.contains("guiadosquadrinhos.com")
                || normalizada.contains("guiadosquadrinhos.com.br");
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

    private String origemApiNormalizada() {
        String base = apiUrlPublica == null || apiUrlPublica.isBlank()
                ? "https://hqhub-backend.onrender.com"
                : apiUrlPublica.trim();
        return base.endsWith("/") ? base.substring(0, base.length() - 1) : base;
    }

    private String origemCompartilhamentoNormalizada() {
        String base = urlCompartilhamentoPublica == null || urlCompartilhamentoPublica.isBlank()
                ? "https://hqhub-backend.onrender.com/api/compartilhar"
                : urlCompartilhamentoPublica.trim();
        return base.endsWith("/") ? base.substring(0, base.length() - 1) : base;
    }

    private String origemRequisicao(UriInfo uriInfo, String protocoloEncaminhado) {
        if (uriInfo == null || uriInfo.getBaseUri() == null) {
            return baseNormalizada();
        }
        URI base = uriInfo.getBaseUri();
        String protocolo = protocoloPublico(protocoloEncaminhado, base.getScheme());
        String origem = protocolo + "://" + base.getAuthority();
        return origem.endsWith("/") ? origem.substring(0, origem.length() - 1) : origem;
    }

    private String protocoloPublico(String protocoloEncaminhado, String protocoloRequisicao) {
        if (protocoloEncaminhado != null && !protocoloEncaminhado.isBlank()) {
            String primeiro = protocoloEncaminhado.split(",", 2)[0].trim();
            if ("http".equalsIgnoreCase(primeiro) || "https".equalsIgnoreCase(primeiro)) {
                return primeiro.toLowerCase();
            }
        }
        return protocoloRequisicao;
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

    private record ApresentacaoCompartilhamento(
            String titulo,
            String descricao,
            String detalhe,
            ContextoCompartilhamento contexto) {
    }

    private enum ContextoCompartilhamento {
        CATALOGO("catalogo", "NOVA HQ NO HQ-HUB", "Nova HQ no HQ-HUB"),
        COLECAO("colecao", "NA COLEÇÃO", "Adicionei esta HQ à minha coleção no HQ-HUB"),
        RECOMENDACAO("recomendacao", "RECOMENDAÇÃO", "Olha essa HQ no HQ-HUB"),
        PROCURADA("procurada", "HQ PROCURADA", "Alguém tem essa edição?"),
        GENERICO("hq", "CONFIRA ESTA HQ", "Confira esta HQ no HQ-HUB");

        private final String parametro;
        private final String rotuloImagem;
        private final String mensagem;

        ContextoCompartilhamento(String parametro, String rotuloImagem, String mensagem) {
            this.parametro = parametro;
            this.rotuloImagem = rotuloImagem;
            this.mensagem = mensagem;
        }

        String parametro() {
            return parametro;
        }

        String rotuloImagem() {
            return rotuloImagem;
        }

        String descricao(String detalhe) {
            if (detalhe == null || detalhe.isBlank() || "Disponível no HQ-HUB".equals(detalhe)) {
                return mensagem + ".";
            }
            return mensagem + " · " + detalhe + ".";
        }

        static ContextoCompartilhamento de(String valor, PostagemFeed postagem) {
            if (valor != null && !valor.isBlank()) {
                String normalizado = valor.trim().toLowerCase(java.util.Locale.ROOT);
                for (ContextoCompartilhamento contexto : values()) {
                    if (contexto.parametro.equals(normalizado)) {
                        return contexto;
                    }
                }
            }
            if (postagem != null && postagem.getItemColecao() != null) {
                return COLECAO;
            }
            if (postagem != null && postagem.getSerieCatalogo() != null) {
                return CATALOGO;
            }
            return GENERICO;
        }
    }
}
