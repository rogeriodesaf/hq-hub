package br.com.hqhub.service;

import java.math.BigDecimal;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import br.com.hqhub.dto.EdicaoImportacaoDTO;
import br.com.hqhub.dto.GeracaoRascunhoGcdDTO;
import br.com.hqhub.dto.HistoriaImportacaoDTO;
import br.com.hqhub.dto.ImportacaoCatalogoDTO;
import br.com.hqhub.dto.OrigemImportacaoCatalogoDTO;
import br.com.hqhub.dto.PublicacaoOriginalImportacaoDTO;
import br.com.hqhub.dto.SerieBrasileiraImportacaoDTO;
import br.com.hqhub.dto.SerieGcdRespostaDTO;
import br.com.hqhub.exception.RegraNegocioException;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class GcdCatalogoService {

    private static final String BASE = "https://www.comics.org";
    private static final int TAMANHO_LOTE_PADRAO = 20;
    private final ObjectMapper objectMapper;
    private final HttpClient http = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(15)).build();

    public GcdCatalogoService(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    public List<SerieGcdRespostaDTO> buscarSeries(String busca) {
        if (busca == null || busca.trim().length() < 2) {
            throw new RegraNegocioException("Informe ao menos 2 caracteres para pesquisar no GCD.");
        }
        JsonNode raiz = obterJson(BASE + "/api/series/name/"
                + URLEncoder.encode(busca.trim(), StandardCharsets.UTF_8).replace("+", "%20") + "/");
        List<SerieGcdRespostaDTO> resultado = new ArrayList<>();
        for (JsonNode serie : raiz.path("results")) {
            resultado.add(new SerieGcdRespostaDTO(
                    texto(serie, "api_url"), texto(serie, "name"), texto(serie, "country"),
                    texto(serie, "language"), inteiro(serie, "year_began"), inteiro(serie, "year_ended"),
                    serie.path("active_issues").size(), null));
        }
        return resultado;
    }

    public PreparacaoGcd preparar(GeracaoRascunhoGcdDTO pedido) {
        validarUrlApi(pedido.apiUrlSerie(), "/api/series/");
        JsonNode serie = obterJson(pedido.apiUrlSerie());
        List<String> urls = new ArrayList<>();
        int inicio = pedido.inicio() == null ? 1 : pedido.inicio();
        int limite = pedido.quantidade() == null ? TAMANHO_LOTE_PADRAO : Math.min(pedido.quantidade(), 25);
        int indice = 0;
        for (JsonNode url : serie.path("active_issues")) {
            indice++;
            if (indice < inicio) continue;
            if (urls.size() >= limite) break;
            validarUrlApi(url.asText(), "/api/issue/");
            urls.add(url.asText());
        }
        String editora = vazioParaNulo(pedido.editora());
        if (editora == null) editora = buscarNomeEditora(texto(serie, "publisher"));
        if (editora == null) editora = "Editora nao informada";
        List<String> avisos = new ArrayList<>();
        int total = serie.path("active_issues").size();
        if (inicio > total) {
            avisos.add("A edicao inicial " + inicio + " ultrapassa as " + total + " edicoes da serie.");
        } else {
            avisos.add("Lote do GCD: edicoes " + inicio + " a " + (inicio + Math.max(0, urls.size() - 1))
                    + " de " + total + ".");
        }
        return new PreparacaoGcd(urls, editora, avisos);
    }

    public EdicaoImportacaoDTO coletarEdicao(String url, String editora, List<String> avisos) {
        validarUrlApi(url, "/api/issue/");
        JsonNode issue = obterJson(url);
        String numero = primeiro(texto(issue, "number"), texto(issue, "descriptor"), "S/N");
        String serieOriginal = primeiro(texto(issue, "series_name"), "Serie GCD");
        LocalDate data = dataParcial(primeiro(texto(issue, "publication_date"), texto(issue, "key_date")));
        List<HistoriaImportacaoDTO> historias = new ArrayList<>();
        int ordem = 1;
        for (JsonNode story : issue.path("story_set")) {
            String titulo = primeiro(texto(story, "title"), texto(story, "feature"), texto(story, "type"));
            if (titulo == null) continue;
            historias.add(new HistoriaImportacaoDTO(
                    ordem++, titulo, titulo, inteiroDecimal(story, "page_count"), texto(story, "synopsis"),
                    new PublicacaoOriginalImportacaoDTO(
                            serieOriginal, numero, data == null ? null : data.getYear(),
                            serieOriginal + " " + numero, null, null, texto(issue, "cover"), url,
                            null, null, null, titulo, null, null, null,
                            texto(story, "notes"), texto(story, "synopsis"))));
        }
        if (historias.isEmpty()) avisos.add("A edicao " + numero + " nao possui historias cadastradas no GCD.");
        return new EdicaoImportacaoDTO(
                numero, texto(issue, "title"), data,
                primeiro(texto(issue, "publication_date"), texto(issue, "key_date")), editora,
                texto(issue, "indicia_publisher"), "Revista", null, null,
                inteiroDecimal(issue, "page_count"), null, preco(texto(issue, "price")),
                texto(issue, "cover"), texto(issue, "notes"), historias);
    }

    public ImportacaoCatalogoDTO montarResultado(
            GeracaoRascunhoGcdDTO pedido, String editora, List<String> urls,
            List<EdicaoImportacaoDTO> edicoes, List<String> avisos) {
        int totalHistorias = edicoes.stream().mapToInt(e -> e.historias() == null ? 0 : e.historias().size()).sum();
        return new ImportacaoCatalogoDTO(
                new OrigemImportacaoCatalogoDTO(null, pedido.apiUrlSerie(), urls,
                        OffsetDateTime.now().toString(), "HQ-HUB / Grand Comics Database"),
                new SerieBrasileiraImportacaoDTO(pedido.tituloSerie(), null, editora, pedido.volume()),
                edicoes.size(), totalHistorias, avisos, edicoes);
    }

    private String buscarNomeEditora(String url) {
        if (url == null) return null;
        try {
            validarUrlApi(url, "/api/publisher/");
            return texto(obterJson(url), "name");
        } catch (RuntimeException erro) {
            return null;
        }
    }

    private JsonNode obterJson(String url) {
        try {
            validarUrlApi(url, "/api/");
            HttpRequest request = HttpRequest.newBuilder(URI.create(url)).timeout(Duration.ofSeconds(30))
                    .header("Accept", "application/json")
                    .header("User-Agent", "HQ-HUB/1.0 (catalog import)").GET().build();
            HttpResponse<String> response = http.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            if (response.statusCode() == 429) {
                long espera = response.headers().firstValue("Retry-After").map(this::segundosRetryAfter)
                        .orElseGet(() -> esperaInformada(response.body()));
                throw new LimiteGcdException(Math.max(60, espera));
            }
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                throw new RegraNegocioException("O GCD respondeu com status " + response.statusCode() + ".");
            }
            return objectMapper.readTree(response.body());
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RegraNegocioException("A consulta ao GCD foi interrompida.");
        } catch (RegraNegocioException e) {
            throw e;
        } catch (Exception e) {
            throw new RegraNegocioException("Nao foi possivel consultar a API do GCD: " + e.getMessage());
        }
    }

    private void validarUrlApi(String valor, String prefixo) {
        try {
            URI uri = URI.create(valor);
            if (!"https".equalsIgnoreCase(uri.getScheme()) || !"www.comics.org".equalsIgnoreCase(uri.getHost())
                    || uri.getPath() == null || !uri.getPath().startsWith(prefixo)) {
                throw new RegraNegocioException("URL da API do GCD invalida.");
            }
        } catch (IllegalArgumentException e) {
            throw new RegraNegocioException("URL da API do GCD invalida.");
        }
    }

    private String texto(JsonNode no, String campo) {
        JsonNode valor = no.path(campo);
        if (valor.isMissingNode() || valor.isNull() || valor.isContainerNode()) return null;
        return vazioParaNulo(valor.asText());
    }

    private Integer inteiro(JsonNode no, String campo) {
        return no.path(campo).isNumber() ? no.path(campo).asInt() : null;
    }

    private Integer inteiroDecimal(JsonNode no, String campo) {
        return no.path(campo).isNumber() ? (int) Math.round(no.path(campo).asDouble()) : null;
    }

    private String vazioParaNulo(String valor) {
        return valor == null || valor.isBlank() ? null : valor.trim();
    }

    private String primeiro(String... valores) {
        for (String valor : valores) if (valor != null && !valor.isBlank()) return valor.trim();
        return null;
    }

    private LocalDate dataParcial(String valor) {
        if (valor == null) return null;
        String limpa = valor.trim().replaceAll("-00$", "-01");
        try {
            if (limpa.matches("\\d{4}")) return LocalDate.of(Integer.parseInt(limpa), 1, 1);
            if (limpa.matches("\\d{4}-\\d{2}")) return LocalDate.parse(limpa + "-01");
            return LocalDate.parse(limpa);
        } catch (Exception e) {
            return null;
        }
    }

    private BigDecimal preco(String valor) {
        if (valor == null) return null;
        String numero = valor.replaceAll("[^0-9,.]", "").replace(',', '.');
        try {
            return numero.isBlank() ? null : new BigDecimal(numero);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private long segundosRetryAfter(String valor) {
        try { return Long.parseLong(valor); }
        catch (NumberFormatException e) { return 3600; }
    }

    private long esperaInformada(String corpo) {
        if (corpo != null) {
            var matcher = java.util.regex.Pattern.compile("available in (\\d+) seconds", java.util.regex.Pattern.CASE_INSENSITIVE)
                    .matcher(corpo);
            if (matcher.find()) return Long.parseLong(matcher.group(1));
        }
        return 3600;
    }

    public static class LimiteGcdException extends RegraNegocioException {
        private final long segundos;

        public LimiteGcdException(long segundos) {
            super("O limite de consultas do GCD foi atingido.");
            this.segundos = segundos;
        }

        public long segundos() {
            return segundos;
        }
    }

    public record PreparacaoGcd(List<String> urls, String editora, List<String> avisos) {
    }
}
