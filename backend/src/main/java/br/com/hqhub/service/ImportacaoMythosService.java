package br.com.hqhub.service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import br.com.hqhub.dto.CadastroEdicaoBrasileiraMythosDTO;
import br.com.hqhub.dto.EdicaoRespostaDTO;
import br.com.hqhub.dto.PreviaProdutoMythosDTO;
import br.com.hqhub.dto.ResultadoCadastroEdicaoBrasileiraMythosDTO;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.Editora;
import br.com.hqhub.entity.Serie;
import br.com.hqhub.entity.TipoSerie;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.EdicaoMapper;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.EditoraRepository;
import br.com.hqhub.repository.SerieRepository;
import br.com.hqhub.service.ProdutoMythosParser.Produto;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class ImportacaoMythosService {
    static final String FONTE_MYTHOS = "MYTHOS";
    static final String FONTE_PIPOCA_NANQUIM = "PIPOCA_NANQUIM";
    private final ProdutoMythosParser parser;
    private final EdicaoRepository edicoes;
    private final EditoraRepository editoras;
    private final SerieRepository series;
    private final ArmazenamentoImagemService armazenamento;
    private final EdicaoMapper mapper;
    private final HttpClient http = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(12)).followRedirects(HttpClient.Redirect.NORMAL).build();

    public ImportacaoMythosService(ProdutoMythosParser parser, EdicaoRepository edicoes, EditoraRepository editoras,
            SerieRepository series, ArmazenamentoImagemService armazenamento, EdicaoMapper mapper) {
        this.parser = parser; this.edicoes = edicoes; this.editoras = editoras; this.series = series; this.armazenamento = armazenamento; this.mapper = mapper;
    }

    public PreviaProdutoMythosDTO analisar(String url) {
        return analisar(url, FONTE_MYTHOS);
    }

    public PreviaProdutoMythosDTO analisarPipoca(String url) {
        return analisar(url, FONTE_PIPOCA_NANQUIM);
    }

    private PreviaProdutoMythosDTO analisar(String url, String fonte) {
        URI uri = validarUrl(url, fonte);
        Produto produto;
        try {
            produto = parser.extrair(carregar(uri));
        } catch (RegraNegocioException excecao) {
            throw excecao;
        } catch (RuntimeException excecao) {
            throw new RegraNegocioException("Falha ao interpretar os dados do produto da Loja Mythos.");
        }
        if (produto.sku() == null || produto.sku().isBlank()) throw new RegraNegocioException("A página da Mythos não informou um SKU.");
        return new PreviaProdutoMythosDTO(uri.toString(), produto.titulo(), new PreviaProdutoMythosDTO.ProdutoMythosDTO(
                produto.serie(), produto.numero(), produto.descricao(), produto.urlCapa(), produto.sku(), produto.codigoBarras(),
                produto.preco(), produto.quantidadePaginas(), produto.formato(), produto.marca()));
    }

    @Transactional
    public ResultadoCadastroEdicaoBrasileiraMythosDTO cadastrar(CadastroEdicaoBrasileiraMythosDTO dto) {
        return cadastrar(dto, FONTE_MYTHOS);
    }

    public ResultadoCadastroEdicaoBrasileiraMythosDTO cadastrarPipoca(CadastroEdicaoBrasileiraMythosDTO dto) {
        return cadastrar(dto, FONTE_PIPOCA_NANQUIM);
    }

    private ResultadoCadastroEdicaoBrasileiraMythosDTO cadastrar(
            CadastroEdicaoBrasileiraMythosDTO dto, String fonte) {
        PreviaProdutoMythosDTO previa = analisar(dto.urlMythos(), fonte);
        Produto produto = parser.extrair(carregar(validarUrl(dto.urlMythos(), fonte)));
        Serie serie = resolverSerie(dto, produto, fonte);
        var porSku = edicoes.buscarPorOrigemExterna(fonte, produto.sku());
        if (porSku.isPresent() && !porSku.get().getSerie().getId().equals(serie.getId())) {
            throw new RegraNegocioException("Este produto da Mythos já está vinculado a outra coleção.");
        }
        Edicao edicao = porSku.or(() -> edicoes.buscarPorNumeroESerie(dto.numero(), serie.getId())).orElse(null);
        boolean criada = edicao == null;
        if (criada) { edicao = new Edicao(); edicao.setSerie(serie); edicao.setNumero(dto.numero().trim()); }
        edicao.setFonteExterna(fonte); edicao.setIdExterno(produto.sku());
        copiar(edicao.getTitulo(), dto.tituloEdicao(), edicao::setTitulo);
        copiar(edicao.getDescricao(), dto.descricao(), edicao::setDescricao);
        if (edicao.getDataPublicacao() == null) edicao.setDataPublicacao(dto.dataPublicacao());
        copiar(edicao.getCodigoBarras(), dto.codigoBarras(), edicao::setCodigoBarras);
        if (edicao.getQuantidadePaginas() == null) edicao.setQuantidadePaginas(dto.quantidadePaginas());
        if (edicao.getPrecoCapa() == null) edicao.setPrecoCapa(dto.precoCapa());
        copiar(edicao.getFormato(), dto.formato(), edicao::setFormato);
        copiar(edicao.getUrlOrigem(), previa.urlMythos(), edicao::setUrlOrigem);
        List<String> avisos = new ArrayList<>();
        boolean capaArmazenada = false;
        if ((edicao.getUrlCapa() == null || edicao.getUrlCapa().isBlank()) && produto.urlCapa() != null) {
            try { edicao.setUrlCapa(armazenamento.salvarCapaPorUrl(produto.urlCapa()).urlImagem()); capaArmazenada = true; }
            catch (RuntimeException excecao) { edicao.setUrlCapa(produto.urlCapa()); avisos.add("A capa foi vinculada pela URL original, mas não pôde ser copiada para o armazenamento próprio."); }
        }
        if (criada) edicoes.persist(edicao);
        EdicaoRespostaDTO resposta = mapper.paraResposta(edicao);
        return new ResultadoCadastroEdicaoBrasileiraMythosDTO(resposta, criada, capaArmazenada, avisos);
    }

    private Serie resolverSerie(CadastroEdicaoBrasileiraMythosDTO dto, Produto produto, String fonte) {
        if (dto.serieId() != null) {
            Serie serie = series.findByIdOptional(dto.serieId()).orElseThrow(() -> new RecursoNaoEncontradoException("Coleção não encontrada."));
            if (serie.getTipoSerie() != TipoSerie.BRASILEIRA) throw new RegraNegocioException("Selecione uma coleção brasileira.");
            return serie;
        }
        if (!Boolean.TRUE.equals(dto.criarNovaSerie()) || dto.tituloSerie() == null || dto.tituloSerie().isBlank()) throw new RegraNegocioException("Selecione uma coleção ou informe o título da nova coleção.");
        String nomeEditora = FONTE_PIPOCA_NANQUIM.equals(fonte) ? "Pipoca & Nanquim" : "Mythos";
        Editora editora = editoras.buscarPorNome(nomeEditora).orElseGet(() -> { Editora nova = new Editora(); nova.setNome(nomeEditora); nova.setFonteExterna(fonte); nova.setIdExterno(fonte.toLowerCase(Locale.ROOT)); editoras.persist(nova); return nova; });
        return series.buscarPorTituloEEditoraEVolume(dto.tituloSerie(), editora.getId(), dto.volumeSerie()).orElseGet(() -> {
            Serie nova = new Serie(); nova.setTitulo(dto.tituloSerie().trim()); nova.setVolume(dto.volumeSerie()); nova.setTipoSerie(TipoSerie.BRASILEIRA); nova.setEditora(editora); nova.setFonteExterna(fonte); nova.setIdExterno("serie:" + dto.tituloSerie().trim().toLowerCase(Locale.ROOT)); nova.setUrlOrigem(dto.urlMythos()); series.persist(nova); return nova;
        });
    }

    private URI validarUrl(String url) {
        return validarUrl(url, FONTE_MYTHOS);
    }

    private URI validarUrl(String url, String fonte) {
        try {
            URI uri = URI.create(url == null ? "" : url.trim()); String host = uri.getHost() == null ? "" : uri.getHost().toLowerCase(Locale.ROOT);
            boolean dominioValido = FONTE_PIPOCA_NANQUIM.equals(fonte)
                    ? (host.equals("pipocaenanquim.com.br") || host.equals("www.pipocaenanquim.com.br"))
                    : (host.equals("lojamythos.com.br") || host.equals("www.lojamythos.com.br"));
            if (!"https".equalsIgnoreCase(uri.getScheme()) || !dominioValido || uri.getUserInfo() != null || uri.getPort() != -1) throw new RegraNegocioException("Informe uma URL HTTPS válida da loja autorizada.");
            return uri;
        } catch (IllegalArgumentException excecao) { throw new RegraNegocioException("Informe uma URL HTTPS válida da Loja Mythos."); }
    }

    private String carregar(URI uri) {
        try {
            HttpRequest request = HttpRequest.newBuilder(uri).timeout(Duration.ofSeconds(20)).header("User-Agent", "Mozilla/5.0 (compatible; ColecionaHQ/1.0)").header("Accept", "text/html,application/xhtml+xml").GET().build();
            HttpResponse<String> resposta = http.send(request, HttpResponse.BodyHandlers.ofString(java.nio.charset.StandardCharsets.UTF_8));
            if (resposta.statusCode() < 200 || resposta.statusCode() >= 300) throw new RegraNegocioException("A Loja Mythos respondeu com status " + resposta.statusCode() + ".");
            return resposta.body();
        } catch (InterruptedException excecao) { Thread.currentThread().interrupt(); throw new RegraNegocioException("A consulta à Loja Mythos foi interrompida."); }
        catch (java.io.IOException excecao) { throw new RegraNegocioException("Não foi possível consultar a Loja Mythos."); }
    }

    private void copiar(String atual, String novo, java.util.function.Consumer<String> destino) { if ((atual == null || atual.isBlank()) && novo != null && !novo.isBlank()) destino.accept(novo.trim()); }
}
