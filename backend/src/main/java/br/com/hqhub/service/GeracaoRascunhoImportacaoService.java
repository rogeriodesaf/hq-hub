package br.com.hqhub.service;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.text.Normalizer;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import br.com.hqhub.dto.EdicaoImportacaoDTO;
import br.com.hqhub.dto.GeracaoRascunhoImportacaoDTO;
import br.com.hqhub.dto.HistoriaImportacaoDTO;
import br.com.hqhub.dto.ImportacaoCatalogoDTO;
import br.com.hqhub.dto.OrigemImportacaoCatalogoDTO;
import br.com.hqhub.dto.PublicacaoOriginalImportacaoDTO;
import br.com.hqhub.dto.SerieBrasileiraImportacaoDTO;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class GeracaoRascunhoImportacaoService {

    private static final String GUIA_BASE = "https://www.guiadosquadrinhos.com";
    private static final Pattern LINK_EDICAO = Pattern.compile("href=[\"']([^\"']*/edicao/[^\"']+)[\"']", Pattern.CASE_INSENSITIVE);
    private static final Pattern HISTORIA = Pattern.compile(
            "<div[^>]+class=[\"']historia[\"'][^>]*>(.*?)</div>(.*?)(?=<div[^>]+class=[\"']historia[\"']|<div class=\"boxpagedcr\"|<a id=\"ampliar_capa\"|</body>)",
            Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
    private static final Pattern PUBLICACAO_ORIGINAL = Pattern.compile(
            "Publicada .*? em\\s+(.+?)\\s+n[°º]\\s*([^/\\s]+)\\s*/\\s*(\\d{4})\\s*-\\s*([^\\n\\r]+)",
            Pattern.CASE_INSENSITIVE);
    private static final DateTimeFormatter DATA_ORIGEM = DateTimeFormatter.ISO_LOCAL_DATE_TIME;

    private final HttpClient httpClient = HttpClient.newBuilder()
            .followRedirects(HttpClient.Redirect.NORMAL)
            .version(HttpClient.Version.HTTP_1_1)
            .build();

    public ImportacaoCatalogoDTO gerar(GeracaoRascunhoImportacaoDTO pedido) {
        List<String> avisos = new ArrayList<>();
        List<String> urlsProcessadas = descobrirUrlsEdicoes(pedido.urlGuia(), pedido.quantidade(), avisos);
        List<EdicaoImportacaoDTO> edicoes = new ArrayList<>();

        for (String urlEdicao : urlsProcessadas) {
            try {
                String html = buscarHtml(urlEdicao);
                edicoes.add(extrairEdicao(html, urlEdicao, pedido.editora(), avisos));
            } catch (Exception e) {
                avisos.add("Nao foi possivel ler a edicao do Guia: " + urlEdicao + " (" + e.getMessage() + ")");
            }
        }

        if (pedido.urlPaniniInicial() != null && !pedido.urlPaniniInicial().isBlank()) {
            aplicarCapasPanini(edicoes, pedido.urlPaniniInicial().trim(), avisos);
        } else {
            avisos.add("Nenhuma URL inicial da Panini foi informada. As capas permaneceram como vieram do Guia.");
        }

        int totalHistorias = edicoes.stream()
                .mapToInt(edicao -> edicao.historias() == null ? 0 : edicao.historias().size())
                .sum();

        return new ImportacaoCatalogoDTO(
                new OrigemImportacaoCatalogoDTO(
                        null,
                        pedido.urlGuia(),
                        urlsProcessadas,
                        LocalDateTime.now().format(DATA_ORIGEM),
                        "HQ-HUB gerador de rascunho"),
                new SerieBrasileiraImportacaoDTO(
                        pedido.tituloSerie(),
                        pedido.fase(),
                        pedido.editora(),
                        pedido.volume()),
                edicoes.size(),
                totalHistorias,
                avisos,
                edicoes);
    }

    private List<String> descobrirUrlsEdicoes(String urlGuia, int quantidade, List<String> avisos) {
        String url = urlGuia.trim();
        if (url.contains("/capas/")) {
            try {
                String html = buscarHtml(url);
                List<String> links = extrairLinksEdicao(html, url);
                if (links.isEmpty()) {
                    avisos.add("A galeria do Guia nao trouxe links de edicao.");
                    return List.of();
                }
                return links.stream().limit(quantidade).toList();
            } catch (Exception e) {
                avisos.add("Nao foi possivel ler a galeria do Guia: " + e.getMessage());
                return List.of();
            }
        }

        if (url.contains("/edicao/")) {
            avisos.add("URL do Guia informada e de edicao. Para gerar varias edicoes automaticamente, prefira a URL /capas/ da serie.");
            return List.of(url);
        }

        avisos.add("URL do Guia nao reconhecida. Informe uma URL /capas/ ou /edicao/.");
        return List.of();
    }

    private List<String> extrairLinksEdicao(String html, String urlBase) {
        Set<String> links = new LinkedHashSet<>();
        Matcher matcher = LINK_EDICAO.matcher(html);
        while (matcher.find()) {
            links.add(resolverUrl(urlBase, matcher.group(1)));
        }
        return links.stream()
                .sorted((a, b) -> Integer.compare(numeroOrdemUrl(a), numeroOrdemUrl(b)))
                .toList();
    }

    private EdicaoImportacaoDTO extrairEdicao(String html, String urlEdicao, String editoraPadrao, List<String> avisos) {
        String texto = htmlParaTexto(html);
        String numero = primeiro("-n-(\\d+[A-Za-z]?)", urlEdicao).orElseGet(() -> primeiro("n[°º]\\s*(\\d+[A-Za-z]?)", texto).orElse(""));
        String publicadoTexto = primeiro("Publicado em:\\s*([^\\n\\r]+)", texto).orElse(null);
        List<HistoriaImportacaoDTO> historias = extrairHistorias(html, avisos);

        if (numero.isBlank()) {
            avisos.add("Uma edicao foi gerada sem numero a partir de " + urlEdicao);
        }
        if (historias.isEmpty()) {
            avisos.add("Edicao " + numero + " nao trouxe historias reconhecidas pelo Guia.");
        }

        return new EdicaoImportacaoDTO(
                numero,
                primeiro("<span id=\"descricao\">(.*?)</span>", html).map(this::limparHtmlEmLinha).orElse(null),
                converterDataPublicacao(publicadoTexto),
                publicadoTexto,
                primeiro("Editora:\\s*([^\\n\\r]+)", texto).orElse(editoraPadrao),
                primeiro("Licenciador:\\s*([^\\n\\r]+)", texto).orElse(null),
                primeiro("Categoria:\\s*([^\\n\\r]+)", texto).orElse(null),
                primeiro("Gênero:\\s*([^\\n\\r]+)", texto).orElse(null),
                primeiro("Status:\\s*([^\\n\\r]+)", texto).orElse(null),
                primeiro("Número de páginas:\\s*(\\d+)", texto).map(Integer::parseInt).orElse(null),
                primeiro("Formato:\\s*([^\\n\\r]+)", texto).orElse(null),
                converterPreco(primeiro("Preço de capa:\\s*R\\$\\s*([0-9,.]+)", texto).orElse(null)),
                extrairCapaGuia(html),
                primeiro("<meta name=\"description\" content=\"([^\"]+)\"", html).map(this::decodificarHtml).orElse(null),
                historias);
    }

    private List<HistoriaImportacaoDTO> extrairHistorias(String html, List<String> avisos) {
        List<HistoriaImportacaoDTO> historias = new ArrayList<>();
        Matcher matcher = HISTORIA.matcher(html);
        int ordem = 1;
        while (matcher.find()) {
            String tituloPortugues = limparHtmlEmLinha(matcher.group(1));
            String blocoTexto = htmlParaTexto(matcher.group(2));
            Matcher publicacao = PUBLICACAO_ORIGINAL.matcher(blocoTexto);
            if (!publicacao.find()) {
                avisos.add("Historia ignorada sem publicacao original reconhecida: " + tituloPortugues);
                continue;
            }

            String serieOriginal = limparTexto(publicacao.group(1));
            String numeroOriginal = limparTexto(publicacao.group(2));
            Integer anoOriginal = Integer.parseInt(publicacao.group(3));
            String editoraOriginal = limparTexto(publicacao.group(4));
            String textoOriginal = serieOriginal + " n° " + numeroOriginal + "/" + anoOriginal + " - " + editoraOriginal;

            historias.add(new HistoriaImportacaoDTO(
                    ordem++,
                    tituloPortugues,
                    primeiro("Título original:\\s*\"([^\"]+)\"", blocoTexto).orElse(null),
                    primeiro("(\\d+)\\s+Páginas", blocoTexto).map(Integer::parseInt).orElse(null),
                    null,
                    new PublicacaoOriginalImportacaoDTO(
                            serieOriginal,
                            numeroOriginal,
                            anoOriginal,
                            textoOriginal,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null)));
        }
        return historias;
    }

    private void aplicarCapasPanini(List<EdicaoImportacaoDTO> edicoes, String urlInicial, List<String> avisos) {
        PadraoPanini padrao = PadraoPanini.extrair(urlInicial);
        if (padrao == null) {
            avisos.add("Nao foi possivel identificar o padrao numerico da Panini. Capas do Guia foram mantidas.");
            return;
        }

        for (int indice = 0; indice < edicoes.size(); indice++) {
            String urlProduto = padrao.montar(indice);
            try {
                String html = buscarHtml(urlProduto);
                String urlCapa = extrairCapaPanini(html).orElse(null);
                if (urlCapa == null) {
                    avisos.add("Capa Panini nao encontrada para " + urlProduto);
                    continue;
                }
                EdicaoImportacaoDTO atual = edicoes.get(indice);
                edicoes.set(indice, new EdicaoImportacaoDTO(
                        atual.numero(),
                        atual.tituloChamada(),
                        atual.dataPublicacao(),
                        atual.publicadoTexto(),
                        atual.editora(),
                        atual.licenciador(),
                        atual.categoria(),
                        atual.genero(),
                        atual.status(),
                        atual.numeroPaginas(),
                        atual.formato(),
                        atual.precoCapa(),
                        urlCapa,
                        atual.descricao(),
                        atual.historias()));
            } catch (Exception e) {
                avisos.add("Nao foi possivel buscar capa Panini em " + urlProduto + " (" + e.getMessage() + ")");
            }
        }
    }

    private String buscarHtml(String url) throws IOException, InterruptedException {
        HttpRequest request = HttpRequest.newBuilder(URI.create(url))
                .version(HttpClient.Version.HTTP_1_1)
                .header("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36")
                .header("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8")
                .header("Accept-Language", "pt-BR,pt;q=0.9,en;q=0.8")
                .header("Cache-Control", "no-cache")
                .header("Pragma", "no-cache")
                .header("Referer", refererPara(url))
                .GET()
                .build();
        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() < 200 || response.statusCode() >= 400) {
            throw new IOException("HTTP " + response.statusCode() + detalheRespostaErro(response.body()));
        }
        return response.body();
    }

    private String refererPara(String url) {
        if (url.contains("guiadosquadrinhos.com")) {
            return "https://www.guiadosquadrinhos.com/";
        }
        if (url.contains("panini.com.br")) {
            return "https://panini.com.br/";
        }
        return "https://www.google.com/";
    }

    private String detalheRespostaErro(String corpo) {
        if (corpo == null || corpo.isBlank()) {
            return "";
        }
        if (corpo.contains("Just a moment") || corpo.contains("challenge-platform")) {
            return ": Bloqueio Cloudflare do site de origem. O servidor nao conseguiu ler esta pagina automaticamente.";
        }
        String texto = htmlParaTexto(corpo);
        if (texto.length() > 120) {
            texto = texto.substring(0, 120);
        }
        return ": " + texto;
    }

    private Optional<String> extrairCapaPanini(String html) {
        return primeiro("property=[\"']og:image[\"']\\s+content=[\"']([^\"']+)[\"']", html)
                .or(() -> primeiro("<link[^>]+itemprop=[\"']image[\"'][^>]+href=[\"']([^\"']+)[\"']", html));
    }

    private String extrairCapaGuia(String html) {
        return primeiro("property=\"og:image\" content=\"([^\"]+)\"", html)
                .map(url -> url.replace("http://", "https://"))
                .orElse(null);
    }

    private Optional<String> primeiro(String regex, String texto) {
        Matcher matcher = Pattern.compile(regex, Pattern.CASE_INSENSITIVE | Pattern.DOTALL).matcher(texto);
        if (!matcher.find()) {
            return Optional.empty();
        }
        return Optional.of(limparTexto(decodificarHtml(matcher.group(1))));
    }

    private String htmlParaTexto(String html) {
        String texto = html
                .replaceAll("(?i)<br\\s*/?>", "\n")
                .replaceAll("(?i)</(div|p|li|h\\d|span)>", "\n")
                .replaceAll("<[^>]+>", " ");
        texto = decodificarHtml(texto);
        texto = texto.replace("\r", "\n").replaceAll("[ \\t]+", " ");
        texto = texto.replaceAll("\\n\\s+", "\n").replaceAll("\\n{2,}", "\n");
        return texto.trim();
    }

    private String limparHtmlEmLinha(String html) {
        return limparTexto(htmlParaTexto(html).replace("\n", " "));
    }

    private String limparTexto(String texto) {
        if (texto == null) {
            return null;
        }
        return texto.replace('\u00a0', ' ').replaceAll("\\s+", " ").trim();
    }

    private String decodificarHtml(String texto) {
        if (texto == null) {
            return null;
        }
        String resultado = texto
                .replace("&nbsp;", " ")
                .replace("&deg;", "°")
                .replace("&ordm;", "º")
                .replace("&ª;", "ª")
                .replace("&amp;", "&")
                .replace("&quot;", "\"")
                .replace("&#39;", "'")
                .replace("&apos;", "'")
                .replace("&ccedil;", "ç")
                .replace("&Ccedil;", "Ç")
                .replace("&aacute;", "á")
                .replace("&Aacute;", "Á")
                .replace("&eacute;", "é")
                .replace("&Eacute;", "É")
                .replace("&iacute;", "í")
                .replace("&Iacute;", "Í")
                .replace("&oacute;", "ó")
                .replace("&Oacute;", "Ó")
                .replace("&uacute;", "ú")
                .replace("&Uacute;", "Ú")
                .replace("&atilde;", "ã")
                .replace("&Atilde;", "Ã")
                .replace("&otilde;", "õ")
                .replace("&Otilde;", "Õ")
                .replace("&acirc;", "â")
                .replace("&ecirc;", "ê")
                .replace("&ocirc;", "ô");

        Matcher decimal = Pattern.compile("&#(\\d+);").matcher(resultado);
        StringBuffer buffer = new StringBuffer();
        while (decimal.find()) {
            decimal.appendReplacement(buffer, Matcher.quoteReplacement(Character.toString((char) Integer.parseInt(decimal.group(1)))));
        }
        decimal.appendTail(buffer);
        return buffer.toString();
    }

    private LocalDate converterDataPublicacao(String texto) {
        if (texto == null || texto.isBlank()) {
            return null;
        }
        String normalizado = Normalizer.normalize(texto.toLowerCase(Locale.ROOT), Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "");
        String[] meses = {
                "janeiro", "fevereiro", "marco", "abril", "maio", "junho",
                "julho", "agosto", "setembro", "outubro", "novembro", "dezembro"
        };
        for (int i = 0; i < meses.length; i++) {
            if (normalizado.contains(meses[i])) {
                Matcher ano = Pattern.compile("(\\d{4})").matcher(normalizado);
                if (ano.find()) {
                    return LocalDate.of(Integer.parseInt(ano.group(1)), i + 1, 1);
                }
            }
        }
        return null;
    }

    private BigDecimal converterPreco(String texto) {
        if (texto == null || texto.isBlank()) {
            return null;
        }
        return new BigDecimal(texto.replace(".", "").replace(",", "."));
    }

    private String resolverUrl(String urlBase, String href) {
        return URI.create(urlBase).resolve(href).toString().replace("http://", "https://");
    }

    private int numeroOrdemUrl(String url) {
        return primeiro("-n-(\\d+)", url).map(Integer::parseInt).orElse(0);
    }

    private record PadraoPanini(String prefixo, int primeiro, int segundo, int larguraPrimeiro, int larguraSegundo, boolean duplo) {
        static PadraoPanini extrair(String url) {
            Matcher duplo = Pattern.compile("^(.+-)(\\d+)-(\\d+)$").matcher(url);
            if (duplo.find()) {
                return new PadraoPanini(
                        duplo.group(1),
                        Integer.parseInt(duplo.group(2)),
                        Integer.parseInt(duplo.group(3)),
                        duplo.group(2).length(),
                        duplo.group(3).length(),
                        true);
            }

            Matcher simples = Pattern.compile("^(.+-)(\\d+)$").matcher(url);
            if (simples.find()) {
                return new PadraoPanini(
                        simples.group(1),
                        Integer.parseInt(simples.group(2)),
                        0,
                        simples.group(2).length(),
                        0,
                        false);
            }

            return null;
        }

        String montar(int deslocamento) {
            String primeiroFormatado = String.valueOf(primeiro + deslocamento);
            if (larguraPrimeiro > 1) {
                primeiroFormatado = String.format("%0" + larguraPrimeiro + "d", primeiro + deslocamento);
            }
            if (!duplo) {
                return prefixo + primeiroFormatado;
            }
            String segundoFormatado = String.valueOf(segundo + deslocamento);
            if (larguraSegundo > 1) {
                segundoFormatado = String.format("%0" + larguraSegundo + "d", segundo + deslocamento);
            }
            return prefixo + primeiroFormatado + "-" + segundoFormatado;
        }
    }
}
