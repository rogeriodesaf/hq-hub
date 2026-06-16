package br.com.hqhub.service;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Duration;
import java.time.Instant;
import java.util.HexFormat;
import java.util.List;
import java.util.Optional;
import java.util.stream.StreamSupport;

import org.eclipse.microprofile.config.inject.ConfigProperty;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import br.com.hqhub.dto.CreditoComicVineRespostaDTO;
import br.com.hqhub.dto.EdicaoComicVineRespostaDTO;
import br.com.hqhub.dto.FonteExternaRespostaDTO;
import br.com.hqhub.dto.PaginaRespostaDTO;
import br.com.hqhub.dto.RespostaBuscaExternaDTO;
import br.com.hqhub.dto.ResultadoBuscaExternaDTO;
import br.com.hqhub.dto.VolumeComicVineRespostaDTO;
import br.com.hqhub.exception.RegraNegocioException;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class IntegracaoExternaService {

    private static final String WIKIPEDIA = "WIKIPEDIA";
    private static final String WIKIDATA = "WIKIDATA";
    private static final String MARVEL = "MARVEL";
    private static final String COMICVINE = "COMICVINE";
    private static final String GCD = "GCD";
    private static final Duration TEMPO_LIMITE_CONEXAO = Duration.ofSeconds(5);
    private static final Duration TEMPO_LIMITE_REQUISICAO = Duration.ofSeconds(15);
    private static final int TAMANHO_PADRAO_COMICVINE = 20;
    private static final int TAMANHO_MAXIMO_COMICVINE = 100;

    private final HttpClient httpClient;
    private final ObjectMapper objectMapper;

    @ConfigProperty(name = "hqhub.integracoes.marvel.chave-publica")
    Optional<String> marvelChavePublica;

    @ConfigProperty(name = "hqhub.integracoes.marvel.chave-privada")
    Optional<String> marvelChavePrivada;

    @ConfigProperty(name = "hqhub.integracoes.comicvine.chave-api")
    Optional<String> comicVineChaveApi;

    public IntegracaoExternaService(ObjectMapper objectMapper) {
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(TEMPO_LIMITE_CONEXAO)
                .build();
        this.objectMapper = objectMapper;
    }

    public List<FonteExternaRespostaDTO> listarFontes() {
        return List.of(
                new FonteExternaRespostaDTO(WIKIPEDIA, "Wikipédia", true, "Busca pública sem chave de API."),
                new FonteExternaRespostaDTO(WIKIDATA, "Wikidata", true, "Busca pública sem chave de API."),
                new FonteExternaRespostaDTO(GCD, "Grand Comics Database", true,
                        "Busca pública pela API oficial do comics.org, com limites de acesso."),
                new FonteExternaRespostaDTO(MARVEL, "Marvel API", marvelConfigurada(),
                        "Requer HQHUB_MARVEL_CHAVE_PUBLICA e HQHUB_MARVEL_CHAVE_PRIVADA."),
                new FonteExternaRespostaDTO(COMICVINE, "ComicVine API", comicVineConfigurada(),
                        "Requer HQHUB_COMICVINE_CHAVE_API."));
    }

    public RespostaBuscaExternaDTO buscar(String fonteExterna, String termo) {
        if (termo == null || termo.isBlank()) {
            throw new RegraNegocioException("Termo de busca é obrigatório.");
        }

        String fonteTratada = fonteExterna.toUpperCase();
        List<ResultadoBuscaExternaDTO> resultados = switch (fonteTratada) {
            case WIKIPEDIA -> buscarWikipedia(termo);
            case WIKIDATA -> buscarWikidata(termo);
            case GCD -> buscarGcd(termo);
            case MARVEL -> buscarMarvel(termo);
            case COMICVINE -> buscarComicVine(termo);
            default -> throw new RegraNegocioException("Fonte externa não suportada.");
        };

        return new RespostaBuscaExternaDTO(fonteTratada, termo, resultados);
    }

    public PaginaRespostaDTO<VolumeComicVineRespostaDTO> buscarVolumesComicVine(
            String termo,
            Integer pagina,
            Integer tamanho) {
        validarComicVineConfigurada();

        if (termo == null || termo.isBlank()) {
            throw new RegraNegocioException("Termo de busca é obrigatório.");
        }

        int paginaTratada = tratarPagina(pagina);
        int tamanhoTratado = tratarTamanhoComicVine(tamanho);
        int offset = paginaTratada * tamanhoTratado;

        String url = "https://comicvine.gamespot.com/api/volumes/?format=json"
                + "&limit=" + tamanhoTratado
                + "&offset=" + offset
                + "&sort=start_year:asc"
                + "&field_list=id,name,start_year,count_of_issues,publisher,site_detail_url,image,deck,description"
                + "&filter=" + codificar("name:" + termo)
                + "&api_key=" + codificar(comicVineChaveApi.orElseThrow());
        JsonNode raiz = executarGet(url);
        List<VolumeComicVineRespostaDTO> itens = StreamSupport.stream(raiz.path("results").spliterator(), false)
                .map(this::montarVolumeComicVine)
                .toList();
        long totalItens = raiz.path("number_of_total_results").asLong(itens.size());

        return new PaginaRespostaDTO<>(itens, paginaTratada, tamanhoTratado, totalItens,
                calcularTotalPaginas(totalItens, tamanhoTratado));
    }

    public PaginaRespostaDTO<EdicaoComicVineRespostaDTO> buscarEdicoesVolumeComicVine(
            String idVolume,
            Integer pagina,
            Integer tamanho) {
        validarComicVineConfigurada();

        if (idVolume == null || idVolume.isBlank()) {
            throw new RegraNegocioException("Identificador do volume é obrigatório.");
        }

        int paginaTratada = tratarPagina(pagina);
        int tamanhoTratado = tratarTamanhoComicVine(tamanho);
        int offset = paginaTratada * tamanhoTratado;

        String url = "https://comicvine.gamespot.com/api/issues/?format=json"
                + "&limit=" + tamanhoTratado
                + "&offset=" + offset
                + "&sort=cover_date:asc"
                + "&field_list=id,name,issue_number,cover_date,store_date,site_detail_url,image,deck,description,person_credits,character_credits,volume"
                + "&filter=" + codificar("volume:" + idVolume)
                + "&api_key=" + codificar(comicVineChaveApi.orElseThrow());
        JsonNode raiz = executarGet(url);
        List<EdicaoComicVineRespostaDTO> itens = StreamSupport.stream(raiz.path("results").spliterator(), false)
                .map(this::montarEdicaoComicVine)
                .toList();
        long totalItens = raiz.path("number_of_total_results").asLong(itens.size());

        return new PaginaRespostaDTO<>(itens, paginaTratada, tamanhoTratado, totalItens,
                calcularTotalPaginas(totalItens, tamanhoTratado));
    }

    private List<ResultadoBuscaExternaDTO> buscarWikipedia(String termo) {
        String url = "https://pt.wikipedia.org/w/api.php?action=query&list=search&format=json&utf8=1&srlimit=10&srsearch="
                + codificar(termo);
        JsonNode raiz = executarGet(url);

        return StreamSupport.stream(raiz.path("query").path("search").spliterator(), false)
                .map(this::montarResultadoWikipedia)
                .toList();
    }

    private ResultadoBuscaExternaDTO montarResultadoWikipedia(JsonNode item) {
        String id = item.path("pageid").asText();
        String titulo = item.path("title").asText();
        String descricao = limparHtml(item.path("snippet").asText());
        String url = "https://pt.wikipedia.org/?curid=" + id;

        return new ResultadoBuscaExternaDTO(WIKIPEDIA, id, "PAGINA", titulo, descricao, url, null);
    }

    private List<ResultadoBuscaExternaDTO> buscarWikidata(String termo) {
        String url = "https://www.wikidata.org/w/api.php?action=wbsearchentities&format=json&language=pt&limit=10&search="
                + codificar(termo);
        JsonNode raiz = executarGet(url);

        return StreamSupport.stream(raiz.path("search").spliterator(), false)
                .map(this::montarResultadoWikidata)
                .toList();
    }

    private ResultadoBuscaExternaDTO montarResultadoWikidata(JsonNode item) {
        String id = item.path("id").asText();
        String titulo = item.path("label").asText();
        String descricao = item.path("description").asText(null);
        String url = item.path("concepturi").asText("https://www.wikidata.org/wiki/" + id);

        return new ResultadoBuscaExternaDTO(WIKIDATA, id, "ENTIDADE", titulo, descricao, url, null);
    }

    private List<ResultadoBuscaExternaDTO> buscarGcd(String termo) {
        String url = "https://www.comics.org/api/series/name/" + codificarCaminho(termo) + "/";
        JsonNode raiz = executarGet(url);
        JsonNode resultados = raiz.has("results") ? raiz.path("results") : raiz;

        return StreamSupport.stream(resultados.spliterator(), false)
                .map(this::montarResultadoGcd)
                .toList();
    }

    private ResultadoBuscaExternaDTO montarResultadoGcd(JsonNode item) {
        String id = item.path("id").asText();
        String titulo = item.path("name").asText(item.path("title").asText());
        String anoInicio = item.path("year_began").asText(null);
        String anoFim = item.path("year_ended").asText(null);
        String descricao = "Série no Grand Comics Database"
                + (anoInicio == null ? "" : ", início: " + anoInicio)
                + (anoFim == null ? "" : ", fim: " + anoFim);
        String url = item.path("url").asText(null);

        if (url == null && !id.isBlank()) {
            url = "https://www.comics.org/series/" + id + "/";
        }

        return new ResultadoBuscaExternaDTO(GCD, id, "SERIE", titulo, descricao, url, null);
    }

    private List<ResultadoBuscaExternaDTO> buscarMarvel(String termo) {
        if (!marvelConfigurada()) {
            throw new RegraNegocioException("Marvel API não configurada. Informe as variáveis HQHUB_MARVEL_CHAVE_PUBLICA e HQHUB_MARVEL_CHAVE_PRIVADA.");
        }

        String timestamp = String.valueOf(Instant.now().toEpochMilli());
        String hash = gerarHashMarvel(timestamp);
        String url = "https://gateway.marvel.com/v1/public/comics?limit=10&titleStartsWith=" + codificar(termo)
                + "&ts=" + timestamp
                + "&apikey=" + codificar(marvelChavePublica.orElseThrow())
                + "&hash=" + hash;
        JsonNode raiz = executarGet(url);

        return StreamSupport.stream(raiz.path("data").path("results").spliterator(), false)
                .map(this::montarResultadoMarvel)
                .toList();
    }

    private ResultadoBuscaExternaDTO montarResultadoMarvel(JsonNode item) {
        String id = item.path("id").asText();
        String titulo = item.path("title").asText();
        String descricao = item.path("description").asText(null);
        String url = extrairPrimeiraUrl(item.path("urls"));
        String imagem = null;

        if (item.has("thumbnail")) {
            imagem = item.path("thumbnail").path("path").asText() + "." + item.path("thumbnail").path("extension").asText();
        }

        return new ResultadoBuscaExternaDTO(MARVEL, id, "EDICAO", titulo, descricao, url, imagem);
    }

    private List<ResultadoBuscaExternaDTO> buscarComicVine(String termo) {
        validarComicVineConfigurada();

        String url = "https://comicvine.gamespot.com/api/search/?format=json&limit=10&resources=issue,volume&query="
                + codificar(termo)
                + "&api_key=" + codificar(comicVineChaveApi.orElseThrow());
        JsonNode raiz = executarGet(url);

        return StreamSupport.stream(raiz.path("results").spliterator(), false)
                .map(this::montarResultadoComicVine)
                .toList();
    }

    private ResultadoBuscaExternaDTO montarResultadoComicVine(JsonNode item) {
        String id = item.path("id").asText();
        String titulo = item.path("name").asText();
        String descricao = limparHtml(item.path("deck").asText(null));
        String url = item.path("site_detail_url").asText(null);
        String imagem = item.path("image").path("original_url").asText(null);
        String tipo = item.path("resource_type").asText("RESULTADO").toUpperCase();

        return new ResultadoBuscaExternaDTO(COMICVINE, id, tipo, titulo, descricao, url, imagem);
    }

    private VolumeComicVineRespostaDTO montarVolumeComicVine(JsonNode item) {
        String id = item.path("id").asText();
        String titulo = item.path("name").asText();
        String editora = item.path("publisher").path("name").asText(null);
        Integer anoInicio = inteiroOuNulo(item.path("start_year"));
        Integer quantidadeEdicoes = inteiroOuNulo(item.path("count_of_issues"));
        String descricao = limparHtml(item.path("deck").asText(item.path("description").asText(null)));
        String url = item.path("site_detail_url").asText(null);
        String imagem = item.path("image").path("original_url").asText(null);

        return new VolumeComicVineRespostaDTO(id, titulo, editora, anoInicio, quantidadeEdicoes, descricao, url, imagem);
    }

    private EdicaoComicVineRespostaDTO montarEdicaoComicVine(JsonNode item) {
        String id = item.path("id").asText();
        String numero = item.path("issue_number").asText(null);
        String titulo = item.path("name").asText(null);
        JsonNode volume = item.path("volume");
        String nomeVolume = volume.path("name").asText(null);
        String idVolume = volume.path("id").asText(null);
        String dataCapa = item.path("cover_date").asText(null);
        String dataVenda = item.path("store_date").asText(null);
        String descricao = limparHtml(item.path("deck").asText(item.path("description").asText(null)));
        String url = item.path("site_detail_url").asText(null);
        String imagem = item.path("image").path("original_url").asText(null);
        List<CreditoComicVineRespostaDTO> creditos = StreamSupport.stream(item.path("person_credits").spliterator(), false)
                .map(this::montarCreditoComicVine)
                .toList();
        List<String> personagens = StreamSupport.stream(item.path("character_credits").spliterator(), false)
                .map(personagem -> personagem.path("name").asText())
                .filter(nome -> !nome.isBlank())
                .toList();

        return new EdicaoComicVineRespostaDTO(id, numero, titulo, nomeVolume, idVolume, dataCapa, dataVenda,
                descricao, url, imagem, creditos, personagens);
    }

    private CreditoComicVineRespostaDTO montarCreditoComicVine(JsonNode item) {
        String id = item.path("id").asText(null);
        String nome = item.path("name").asText(null);
        String papel = item.path("role").asText(null);
        String url = item.path("site_detail_url").asText(null);

        return new CreditoComicVineRespostaDTO(id, nome, papel, url);
    }

    private JsonNode executarGet(String url) {
        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .timeout(TEMPO_LIMITE_REQUISICAO)
                    .header("Accept", "application/json")
                    .header("User-Agent", "HQ-HUB/1.0")
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                throw new RegraNegocioException("Falha ao consultar API externa. Status: " + response.statusCode());
            }

            return objectMapper.readTree(response.body());
        } catch (IOException e) {
            throw new RegraNegocioException("Falha ao consultar API externa. Verifique sua conexão, chave de API e tente novamente.");
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RegraNegocioException("Consulta à API externa foi interrompida.");
        }
    }

    private String extrairPrimeiraUrl(JsonNode urls) {
        if (!urls.isArray() || urls.isEmpty()) {
            return null;
        }

        return urls.get(0).path("url").asText(null);
    }

    private String limparHtml(String texto) {
        if (texto == null) {
            return null;
        }

        return texto.replaceAll("<[^>]*>", "").replace("&quot;", "\"").replace("&amp;", "&");
    }

    private Integer inteiroOuNulo(JsonNode valor) {
        if (valor == null || valor.isMissingNode() || valor.isNull() || valor.asText().isBlank()) {
            return null;
        }

        return valor.asInt();
    }

    private int tratarPagina(Integer pagina) {
        if (pagina == null || pagina < 0) {
            return 0;
        }

        return pagina;
    }

    private int tratarTamanhoComicVine(Integer tamanho) {
        if (tamanho == null || tamanho <= 0) {
            return TAMANHO_PADRAO_COMICVINE;
        }

        return Math.min(tamanho, TAMANHO_MAXIMO_COMICVINE);
    }

    private int calcularTotalPaginas(long totalItens, int tamanho) {
        if (totalItens == 0) {
            return 0;
        }

        return (int) Math.ceil((double) totalItens / tamanho);
    }

    private String codificar(String valor) {
        return URLEncoder.encode(valor, StandardCharsets.UTF_8);
    }

    private String codificarCaminho(String valor) {
        return codificar(valor).replace("+", "%20");
    }

    private boolean marvelConfigurada() {
        return marvelChavePublica.filter(chave -> !chave.isBlank()).isPresent()
                && marvelChavePrivada.filter(chave -> !chave.isBlank()).isPresent();
    }

    private boolean comicVineConfigurada() {
        return comicVineChaveApi.filter(chave -> !chave.isBlank()).isPresent();
    }

    private void validarComicVineConfigurada() {
        if (!comicVineConfigurada()) {
            throw new RegraNegocioException("ComicVine API não configurada. Informe a variável HQHUB_COMICVINE_CHAVE_API.");
        }
    }

    private String gerarHashMarvel(String timestamp) {
        try {
            String base = timestamp + marvelChavePrivada.orElseThrow() + marvelChavePublica.orElseThrow();
            MessageDigest digest = MessageDigest.getInstance("MD5");
            return HexFormat.of().formatHex(digest.digest(base.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException e) {
            throw new RegraNegocioException("Não foi possível gerar autenticação da Marvel API.");
        }
    }
}
