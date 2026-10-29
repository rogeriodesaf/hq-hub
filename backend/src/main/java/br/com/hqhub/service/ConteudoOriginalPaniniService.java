package br.com.hqhub.service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.text.Normalizer;
import java.time.Duration;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import br.com.hqhub.dto.CadastroConteudoOriginalPaniniDTO;
import br.com.hqhub.dto.CadastroEdicaoBrasileiraPaniniDTO;
import br.com.hqhub.dto.CadastroEdicaoOriginalPaniniDTO;
import br.com.hqhub.dto.CadastroEdicoesOriginaisPaniniDTO;
import br.com.hqhub.dto.CadastroEdicoesOriginaisPaniniDTO.ReferenciaEdicaoOriginalPaniniDTO;
import br.com.hqhub.dto.EdicaoComicVineRespostaDTO;
import br.com.hqhub.dto.PreviaConteudoOriginalPaniniDTO;
import br.com.hqhub.dto.PreviaConteudoOriginalPaniniDTO.CandidatoEdicaoOriginalPaniniDTO;
import br.com.hqhub.dto.PreviaConteudoOriginalPaniniDTO.ReferenciaConteudoOriginalPaniniDTO;
import br.com.hqhub.dto.ResultadoCadastroConteudoOriginalPaniniDTO;
import br.com.hqhub.dto.ResultadoCadastroEdicaoBrasileiraPaniniDTO;
import br.com.hqhub.dto.ResultadoCadastroEdicoesOriginaisPaniniDTO;
import br.com.hqhub.dto.ResultadoCadastroEdicoesOriginaisPaniniDTO.ResultadoEdicaoOriginalPaniniDTO;
import br.com.hqhub.dto.VolumeComicVineRespostaDTO;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.Editora;
import br.com.hqhub.entity.PublicacaoRelacionada;
import br.com.hqhub.entity.Serie;
import br.com.hqhub.entity.TipoPublicacaoRelacionada;
import br.com.hqhub.entity.TipoSerie;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.EditoraRepository;
import br.com.hqhub.repository.PublicacaoRelacionadaRepository;
import br.com.hqhub.repository.SerieRepository;
import br.com.hqhub.mapper.EdicaoMapper;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class ConteudoOriginalPaniniService {

    private static final String FONTE_PANINI = "PANINI";
    private final EdicaoRepository edicaoRepository;
    private final PublicacaoRelacionadaRepository publicacaoRelacionadaRepository;
    private final ConteudoOriginalPaniniParser parser;
    private final IntegracaoExternaService integracaoExternaService;
    private final EditoraRepository editoraRepository;
    private final SerieRepository serieRepository;
    private final ArmazenamentoImagemService armazenamentoImagemService;
    private final EdicaoMapper edicaoMapper;
    private final HttpClient httpClient;

    public ConteudoOriginalPaniniService(
            EdicaoRepository edicaoRepository,
            PublicacaoRelacionadaRepository publicacaoRelacionadaRepository,
            ConteudoOriginalPaniniParser parser,
            IntegracaoExternaService integracaoExternaService,
            EditoraRepository editoraRepository,
            SerieRepository serieRepository,
            ArmazenamentoImagemService armazenamentoImagemService,
            EdicaoMapper edicaoMapper) {
        this.edicaoRepository = edicaoRepository;
        this.publicacaoRelacionadaRepository = publicacaoRelacionadaRepository;
        this.parser = parser;
        this.integracaoExternaService = integracaoExternaService;
        this.editoraRepository = editoraRepository;
        this.serieRepository = serieRepository;
        this.armazenamentoImagemService = armazenamentoImagemService;
        this.edicaoMapper = edicaoMapper;
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(12))
                .followRedirects(HttpClient.Redirect.NEVER)
                .build();
    }

    @Transactional
    public CandidatoEdicaoOriginalPaniniDTO cadastrarEdicaoOriginal(CadastroEdicaoOriginalPaniniDTO dto) {
        PreviaConteudoOriginalPaniniDTO previa = analisar(dto.urlPanini());
        boolean declaradaPelaPanini = previa.referencias().stream().anyMatch(referencia ->
                normalizar(referencia.serie()).equals(normalizar(dto.serie()))
                        && java.util.Objects.equals(referencia.anoSerie(), dto.anoSerie())
                        && normalizar(referencia.numero()).equals(normalizar(dto.numero())));
        if (!declaradaPelaPanini) {
            throw new RegraNegocioException("A edição solicitada não consta no conteúdo original da página da Panini.");
        }

        ResolucaoComicVine resolucao = resolverEdicaoComicVine(dto);
        EdicaoComicVineRespostaDTO externa = resolucao.edicao();
        Edicao edicao = edicaoRepository.buscarPorOrigemExterna("COMICVINE", externa.idExterno())
                .orElseGet(() -> criarEdicaoComicVine(externa, resolucao.volume(), dto));
        return paraCandidato(edicao);
    }

    @Transactional
    public ResultadoCadastroEdicoesOriginaisPaniniDTO cadastrarEdicoesOriginais(
            CadastroEdicoesOriginaisPaniniDTO dto) {
        PreviaConteudoOriginalPaniniDTO previa = analisar(dto.urlPanini());
        validarReferenciasLote(dto.referencias(), previa);

        Map<GrupoSerie, List<ReferenciaEdicaoOriginalPaniniDTO>> grupos = new LinkedHashMap<>();
        for (ReferenciaEdicaoOriginalPaniniDTO referencia : dto.referencias()) {
            GrupoSerie grupo = new GrupoSerie(normalizarSerie(referencia.serie()), referencia.anoSerie());
            grupos.computeIfAbsent(grupo, ignorado -> new ArrayList<>()).add(referencia);
        }

        Map<Integer, ResolucaoReferenciaLote> resolucoes = resolverGruposComicVine(grupos);
        Map<String, CandidatoEdicaoOriginalPaniniDTO> candidatosPorEdicaoExterna = new LinkedHashMap<>();
        List<ResultadoEdicaoOriginalPaniniDTO> resultados = new ArrayList<>();
        for (ReferenciaEdicaoOriginalPaniniDTO referencia : dto.referencias()) {
            ResolucaoReferenciaLote resolucao = resolucoes.get(referencia.indice());
            if (resolucao == null || resolucao.erro() != null) {
                resultados.add(new ResultadoEdicaoOriginalPaniniDTO(
                        referencia.indice(), null,
                        resolucao == null ? "A referência não foi processada." : resolucao.erro()));
                continue;
            }
            try {
                EdicaoComicVineRespostaDTO externa = resolucao.resolucao().edicao();
                CandidatoEdicaoOriginalPaniniDTO candidato = candidatosPorEdicaoExterna.get(externa.idExterno());
                if (candidato == null) {
                    CadastroEdicaoOriginalPaniniDTO cadastro = new CadastroEdicaoOriginalPaniniDTO(
                            dto.urlPanini(), referencia.serie(), referencia.anoSerie(), referencia.numero());
                    Edicao edicao = edicaoRepository.buscarPorOrigemExterna("COMICVINE", externa.idExterno())
                            .orElseGet(() -> criarEdicaoComicVine(
                                    externa, resolucao.resolucao().volume(), cadastro));
                    candidato = paraCandidato(edicao);
                    candidatosPorEdicaoExterna.put(externa.idExterno(), candidato);
                }
                resultados.add(new ResultadoEdicaoOriginalPaniniDTO(referencia.indice(), candidato, null));
            } catch (RuntimeException excecao) {
                resultados.add(new ResultadoEdicaoOriginalPaniniDTO(
                        referencia.indice(), null, mensagemErro(excecao)));
            }
        }
        return new ResultadoCadastroEdicoesOriginaisPaniniDTO(resultados);
    }

    @Transactional
    public ResultadoCadastroEdicaoBrasileiraPaniniDTO cadastrarEdicaoBrasileira(
            CadastroEdicaoBrasileiraPaniniDTO dto) {
        PreviaConteudoOriginalPaniniDTO previa = analisar(dto.urlPanini());
        var produto = previa.produto();
        if (produto == null || produto.sku() == null || produto.sku().isBlank()) {
            throw new RegraNegocioException("A página da Panini não informou um SKU para identificar o produto.");
        }

        List<String> avisos = new ArrayList<>();
        Serie serie = resolverSerieBrasileiraDestino(dto, previa);

        var porSku = edicaoRepository.buscarPorOrigemExterna(FONTE_PANINI, produto.sku());
        if (porSku.isPresent() && !porSku.get().getSerie().getId().equals(serie.getId())) {
            throw new RegraNegocioException(
                    "Este produto da Panini já está vinculado a outra coleção. Revise a coleção de destino.");
        }
        var porNumero = edicaoRepository.buscarPorNumeroESerie(dto.numero(), serie.getId());
        Edicao edicao = porSku.or(() -> porNumero).orElse(null);
        boolean criada = edicao == null;
        if (criada) {
            edicao = new Edicao();
            edicao.setSerie(serie);
            edicao.setNumero(dto.numero().trim());
            edicao.setFonteExterna(FONTE_PANINI);
            edicao.setIdExterno(produto.sku());
        } else {
            avisos.add("A edição já existia e recebeu apenas os dados ausentes da Panini.");
            if (edicao.getFonteExterna() == null && edicao.getIdExterno() == null) {
                edicao.setFonteExterna(FONTE_PANINI);
                edicao.setIdExterno(produto.sku());
            }
        }

        aplicarDadosProdutoPanini(edicao, dto, previa);
        boolean capaArmazenada = false;
        if ((edicao.getUrlCapa() == null || edicao.getUrlCapa().isBlank())
                && produto.urlCapa() != null && !produto.urlCapa().isBlank()) {
            try {
                edicao.setUrlCapa(armazenamentoImagemService.salvarCapaPorUrl(produto.urlCapa()).urlImagem());
                capaArmazenada = true;
            } catch (RuntimeException excecao) {
                edicao.setUrlCapa(produto.urlCapa());
                avisos.add("A capa oficial foi vinculada pela URL da Panini, mas não pôde ser copiada para o armazenamento próprio.");
            }
        }
        if (criada) {
            edicaoRepository.persist(edicao);
        }
        return new ResultadoCadastroEdicaoBrasileiraPaniniDTO(
                edicaoMapper.paraResposta(edicao), criada, capaArmazenada, avisos);
    }

    Serie resolverSerieBrasileiraDestino(
            CadastroEdicaoBrasileiraPaniniDTO dto,
            PreviaConteudoOriginalPaniniDTO previa) {
        if (dto.serieId() != null) {
            Serie serie = serieRepository.findByIdOptional(dto.serieId())
                    .orElseThrow(() -> new RecursoNaoEncontradoException("A coleção de destino não foi encontrada."));
            if (serie.getTipoSerie() != TipoSerie.BRASILEIRA) {
                throw new RegraNegocioException("Selecione uma coleção brasileira como destino.");
            }
            return serie;
        }
        if (!Boolean.TRUE.equals(dto.criarNovaSerie())) {
            throw new RegraNegocioException("Selecione a coleção já cadastrada ou confirme a criação de uma nova coleção.");
        }
        if (dto.tituloSerie() == null || dto.tituloSerie().isBlank()) {
            throw new RegraNegocioException("Informe o título da nova coleção.");
        }

        Editora editora = editoraRepository.buscarPorNome("Panini").orElseGet(() -> {
            Editora nova = new Editora();
            nova.setNome("Panini");
            nova.setFonteExterna(FONTE_PANINI);
            nova.setIdExterno("panini");
            editoraRepository.persist(nova);
            return nova;
        });
        if (serieRepository.buscarPorTituloEEditoraEVolume(
                dto.tituloSerie(), editora.getId(), dto.volumeSerie()).isPresent()) {
            throw new RegraNegocioException(
                    "Esta coleção já existe. Pesquise e selecione-a como coleção de destino.");
        }
        Serie nova = new Serie();
        nova.setTitulo(dto.tituloSerie().trim());
        nova.setVolume(dto.volumeSerie());
        nova.setAnoInicio(dto.dataPublicacao() == null ? null : dto.dataPublicacao().getYear());
        nova.setTipoSerie(TipoSerie.BRASILEIRA);
        nova.setEditora(editora);
        nova.setFonteExterna(FONTE_PANINI);
        nova.setIdExterno("serie:" + normalizar(dto.tituloSerie())
                + (dto.volumeSerie() == null ? "" : ":v" + dto.volumeSerie()));
        nova.setUrlOrigem(previa.urlPanini());
        serieRepository.persist(nova);
        return nova;
    }

    @Transactional
    public PreviaConteudoOriginalPaniniDTO analisar(String url) {
        URI uri = validarUrlPanini(url);
        String html = carregarPagina(uri);
        ConteudoOriginalPaniniParser.PaginaPanini pagina = parser.extrair(html);
        if ((pagina.conteudoOriginal() == null || pagina.conteudoOriginal().isBlank())
                && (pagina.produto() == null || pagina.produto().sku() == null)) {
            throw new RegraNegocioException("A página informada não possui dados de produto nem Conteúdo original.");
        }

        List<ReferenciaConteudoOriginalPaniniDTO> referencias = pagina.referencias().stream()
                .map(referencia -> {
                    List<CandidatoEdicaoOriginalPaniniDTO> candidatos = buscarCandidatos(referencia);
                    String status = referencia.serie() == null ? "NAO_INTERPRETADA"
                            : candidatos.isEmpty() ? "NAO_ENCONTRADA"
                            : candidatos.size() == 1 ? "ENCONTRADA" : "AMBIGUA";
                    return new ReferenciaConteudoOriginalPaniniDTO(
                            pagina.referencias().indexOf(referencia),
                            referencia.textoOriginal(),
                            referencia.serie(),
                            referencia.anoSerie(),
                            referencia.numero(),
                            referencia.complemento(),
                            status,
                            candidatos);
                })
                .toList();

        var produto = pagina.produto();
        var produtoDto = produto == null ? null : new PreviaConteudoOriginalPaniniDTO.ProdutoPaniniDTO(
                produto.tituloSerieSugerido(), produto.numeroSugerido(), produto.numeroAlternativo(),
                produto.descricao(), produto.urlCapa(), produto.sku(), produto.isbn(), produto.preco(),
                produto.dataDisponibilidade(), produto.quantidadePaginas(), produto.formato(),
                produto.classificacaoEtaria(), produto.categoria(), produto.marca(), produto.autores());
        return new PreviaConteudoOriginalPaniniDTO(
                uri.toString(), pagina.titulo(), pagina.conteudoOriginal(), referencias, produtoDto);
    }

    private void aplicarDadosProdutoPanini(
            Edicao edicao,
            CadastroEdicaoBrasileiraPaniniDTO dto,
            PreviaConteudoOriginalPaniniDTO previa) {
        var produto = previa.produto();
        copiarSeVazio(edicao.getTitulo(), dto.tituloEdicao(), edicao::setTitulo);
        copiarSeVazio(edicao.getDescricao(), dto.descricao(), edicao::setDescricao);
        copiarSeVazio(edicao.getDescricaoOriginal(), dto.descricao(), edicao::setDescricaoOriginal);
        copiarSeVazio(edicao.getDescricaoPortugues(), dto.descricao(), edicao::setDescricaoPortugues);
        if (edicao.getDataPublicacao() == null) edicao.setDataPublicacao(dto.dataPublicacao());
        if (edicao.getDataDisponibilidadeLoja() == null) edicao.setDataDisponibilidadeLoja(dto.dataPublicacao());
        copiarSeVazio(edicao.getCodigoBarras(), dto.codigoBarras(), edicao::setCodigoBarras);
        if (edicao.getQuantidadePaginas() == null) edicao.setQuantidadePaginas(dto.quantidadePaginas());
        if (edicao.getPrecoCapa() == null) edicao.setPrecoCapa(dto.precoCapa());
        copiarSeVazio(edicao.getFormato(), dto.formato(), edicao::setFormato);
        copiarSeVazio(edicao.getUrlOrigem(), previa.urlPanini(), edicao::setUrlOrigem);
        if (edicao.getFonteExterna() == null || edicao.getFonteExterna().isBlank()) {
            edicao.setFonteExterna(FONTE_PANINI);
            edicao.setIdExterno(produto.sku());
        }
    }

    private void copiarSeVazio(String atual, String novoValor, java.util.function.Consumer<String> destino) {
        if ((atual == null || atual.isBlank()) && novoValor != null && !novoValor.isBlank()) {
            destino.accept(novoValor.trim());
        }
    }

    @Transactional
    public ResultadoCadastroConteudoOriginalPaniniDTO cadastrar(CadastroConteudoOriginalPaniniDTO dto) {
        URI uri = validarUrlPanini(dto.urlPanini());
        Edicao brasileira = buscarEdicao(dto.edicaoBrasileiraId());
        if (brasileira.getSerie().getTipoSerie() != TipoSerie.BRASILEIRA) {
            throw new RegraNegocioException("A edição de destino precisa pertencer ao catálogo brasileiro.");
        }

        int cadastrados = 0;
        int jaExistentes = 0;
        Set<Long> idsProcessados = new LinkedHashSet<>();
        for (CadastroConteudoOriginalPaniniDTO.VinculoConteudoOriginalPaniniDTO vinculo : dto.vinculos()) {
            if (!idsProcessados.add(vinculo.edicaoOriginalId())) {
                continue;
            }
            Edicao original = buscarEdicao(vinculo.edicaoOriginalId());
            if (original.getSerie().getTipoSerie() != TipoSerie.ESTRANGEIRA) {
                throw new RegraNegocioException("A edição original de ID " + original.getId() + " não é estrangeira.");
            }
            if (publicacaoRelacionadaRepository.existePorOrigemDestinoTipo(
                    original.getId(), brasileira.getId(), TipoPublicacaoRelacionada.PUBLICADA_NO_BRASIL)) {
                jaExistentes++;
                continue;
            }

            PublicacaoRelacionada publicacao = new PublicacaoRelacionada();
            publicacao.setEdicaoOrigem(original);
            publicacao.setEdicaoDestino(brasileira);
            publicacao.setTipo(TipoPublicacaoRelacionada.PUBLICADA_NO_BRASIL);
            publicacao.setFonteExterna(FONTE_PANINI);
            publicacao.setUrlOrigem(uri.toString());
            publicacao.setObservacoes("Referência declarada pela Panini: " + vinculo.referenciaOriginal().trim());
            publicacaoRelacionadaRepository.persist(publicacao);
            cadastrados++;
        }
        return new ResultadoCadastroConteudoOriginalPaniniDTO(cadastrados, jaExistentes);
    }

    private List<CandidatoEdicaoOriginalPaniniDTO> buscarCandidatos(
            ConteudoOriginalPaniniParser.ReferenciaExtraida referencia) {
        if (referencia.serie() == null || referencia.numero() == null) {
            return List.of();
        }
        String busca = referencia.serie() + " " + referencia.numero();
        return edicaoRepository.buscarPaginado(null, busca, 0, 50, TipoSerie.ESTRANGEIRA).stream()
                .filter(edicao -> normalizarSerie(edicao.getSerie().getTitulo()).equals(normalizarSerie(referencia.serie())))
                .filter(edicao -> normalizar(edicao.getNumero()).equals(normalizar(referencia.numero())))
                .filter(edicao -> referencia.anoSerie() == null
                        || referencia.anoSerie().equals(edicao.getSerie().getAnoInicio()))
                .limit(5)
                .map(edicao -> new CandidatoEdicaoOriginalPaniniDTO(
                        edicao.getId(), edicao.getSerie().getTitulo(), edicao.getNumero(),
                        edicao.getSerie().getAnoInicio(), edicao.getSerie().getEditora().getNome(), edicao.getUrlCapa()))
                .toList();
    }

    private ResolucaoComicVine resolverEdicaoComicVine(CadastroEdicaoOriginalPaniniDTO dto) {
        VolumeComicVineRespostaDTO volume = resolverVolumeComicVine(dto.serie(), dto.anoSerie());
        List<EdicaoComicVineRespostaDTO> encontradas = new java.util.ArrayList<>();
        int pagina = 0;
        int totalPaginas = 1;
        do {
            var resposta = integracaoExternaService.buscarEdicoesVolumeComicVine(volume.idExterno(), pagina, 100);
            resposta.itens().stream()
                    .filter(edicao -> normalizar(edicao.numero()).equals(normalizar(dto.numero())))
                    .forEach(encontradas::add);
            totalPaginas = resposta.totalPaginas();
            pagina++;
        } while (encontradas.isEmpty() && pagina < totalPaginas && pagina < 20);

        if (encontradas.size() != 1) {
            throw new RegraNegocioException(encontradas.isEmpty()
                    ? "A série foi encontrada na Comic Vine, mas a edição #" + dto.numero() + " não foi localizada."
                    : "A Comic Vine encontrou mais de uma edição #" + dto.numero() + " nesta série.");
        }
        return new ResolucaoComicVine(
                integracaoExternaService.buscarDetalheEdicaoComicVine(encontradas.getFirst().idExterno()),
                volume);
    }

    private Map<Integer, ResolucaoReferenciaLote> resolverGruposComicVine(
            Map<GrupoSerie, List<ReferenciaEdicaoOriginalPaniniDTO>> grupos) {
        int paralelismo = Math.min(2, grupos.size());
        ExecutorService executor = Executors.newFixedThreadPool(Math.max(1, paralelismo));
        try {
            List<CompletableFuture<Map<Integer, ResolucaoReferenciaLote>>> tarefas = grupos.values().stream()
                    .map(referencias -> CompletableFuture.supplyAsync(
                            () -> resolverGrupoComicVine(referencias), executor))
                    .toList();
            Map<Integer, ResolucaoReferenciaLote> resultados = new LinkedHashMap<>();
            tarefas.forEach(tarefa -> resultados.putAll(tarefa.join()));
            return resultados;
        } finally {
            executor.shutdown();
        }
    }

    private Map<Integer, ResolucaoReferenciaLote> resolverGrupoComicVine(
            List<ReferenciaEdicaoOriginalPaniniDTO> referencias) {
        Map<Integer, ResolucaoReferenciaLote> resultados = new LinkedHashMap<>();
        ReferenciaEdicaoOriginalPaniniDTO primeira = referencias.getFirst();
        try {
            VolumeComicVineRespostaDTO volume = resolverVolumeComicVine(primeira.serie(), primeira.anoSerie());
            Set<String> numerosPendentes = referencias.stream()
                    .map(referencia -> normalizar(referencia.numero()))
                    .collect(java.util.stream.Collectors.toCollection(LinkedHashSet::new));
            Map<String, List<EdicaoComicVineRespostaDTO>> edicoesPorNumero = new LinkedHashMap<>();
            int pagina = 0;
            int totalPaginas = 1;
            do {
                var resposta = integracaoExternaService.buscarEdicoesVolumeComicVine(
                        volume.idExterno(), pagina, 100);
                for (EdicaoComicVineRespostaDTO edicao : resposta.itens()) {
                    String numero = normalizar(edicao.numero());
                    if (numerosPendentes.contains(numero)) {
                        edicoesPorNumero.computeIfAbsent(numero, ignorado -> new ArrayList<>()).add(edicao);
                    }
                }
                numerosPendentes.removeIf(edicoesPorNumero::containsKey);
                totalPaginas = resposta.totalPaginas();
                pagina++;
            } while (!numerosPendentes.isEmpty() && pagina < totalPaginas && pagina < 20);

            Map<String, ResolucaoComicVine> detalhesPorNumero = new LinkedHashMap<>();
            for (ReferenciaEdicaoOriginalPaniniDTO referencia : referencias) {
                String numero = normalizar(referencia.numero());
                List<EdicaoComicVineRespostaDTO> encontradas = edicoesPorNumero.getOrDefault(numero, List.of());
                if (encontradas.size() != 1) {
                    String erro = encontradas.isEmpty()
                            ? "A série foi encontrada na Comic Vine, mas a edição #" + referencia.numero()
                                    + " não foi localizada."
                            : "A Comic Vine encontrou mais de uma edição #" + referencia.numero()
                                    + " nesta série.";
                    resultados.put(referencia.indice(), new ResolucaoReferenciaLote(null, erro));
                    continue;
                }
                try {
                    ResolucaoComicVine resolucao = detalhesPorNumero.computeIfAbsent(numero, ignorado ->
                            new ResolucaoComicVine(
                                    integracaoExternaService.buscarDetalheEdicaoComicVine(
                                            encontradas.getFirst().idExterno()),
                                    volume));
                    resultados.put(referencia.indice(), new ResolucaoReferenciaLote(resolucao, null));
                } catch (RuntimeException excecao) {
                    resultados.put(referencia.indice(), new ResolucaoReferenciaLote(null, mensagemErro(excecao)));
                }
            }
        } catch (RuntimeException excecao) {
            String erro = mensagemErro(excecao);
            referencias.forEach(referencia ->
                    resultados.put(referencia.indice(), new ResolucaoReferenciaLote(null, erro)));
        }
        return resultados;
    }

    private VolumeComicVineRespostaDTO resolverVolumeComicVine(String serie, Integer anoSerie) {
        List<VolumeComicVineRespostaDTO> volumesPorTitulo = integracaoExternaService
                .buscarVolumesComicVine(serie, 0, 100).itens().stream()
                .filter(volume -> normalizarSerie(volume.titulo()).equals(normalizarSerie(serie)))
                .toList();
        List<VolumeComicVineRespostaDTO> volumes = anoSerie == null
                ? volumesPorTitulo
                : volumesPorTitulo.stream()
                        .filter(volume -> anoSerie.equals(volume.anoInicio()))
                        .toList();
        if (volumes.isEmpty() && anoSerie != null) {
            volumes = volumesPorTitulo.stream()
                    .filter(volume -> volume.anoInicio() != null
                            && Math.abs(volume.anoInicio() - anoSerie) == 1)
                    .toList();
        }
        if (volumes.size() != 1) {
            throw new RegraNegocioException(volumes.isEmpty()
                    ? "A Comic Vine não encontrou um volume único compatível com a série e o ano informados pela Panini."
                    : "A Comic Vine encontrou mais de uma série possível; informe o ID manual após conferir.");
        }
        return volumes.getFirst();
    }

    private void validarReferenciasLote(
            List<ReferenciaEdicaoOriginalPaniniDTO> referencias,
            PreviaConteudoOriginalPaniniDTO previa) {
        Set<Integer> indices = new LinkedHashSet<>();
        for (ReferenciaEdicaoOriginalPaniniDTO referencia : referencias) {
            if (!indices.add(referencia.indice())) {
                throw new RegraNegocioException("A lista possui referências duplicadas.");
            }
            boolean declarada = previa.referencias().stream().anyMatch(item ->
                    normalizar(item.serie()).equals(normalizar(referencia.serie()))
                            && Objects.equals(item.anoSerie(), referencia.anoSerie())
                            && normalizar(item.numero()).equals(normalizar(referencia.numero())));
            if (!declarada) {
                throw new RegraNegocioException(
                        "A referência #" + referencia.indice() + " não consta no conteúdo original da Panini.");
            }
        }
    }

    private String mensagemErro(Throwable excecao) {
        Throwable atual = excecao;
        while (atual.getCause() != null) {
            atual = atual.getCause();
        }
        return atual.getMessage() == null || atual.getMessage().isBlank()
                ? "Não foi possível resolver esta referência na Comic Vine."
                : atual.getMessage();
    }

    private Edicao criarEdicaoComicVine(
            EdicaoComicVineRespostaDTO externa,
            VolumeComicVineRespostaDTO volume,
            CadastroEdicaoOriginalPaniniDTO dto) {
        String nomeEditora = externa.editora() == null || externa.editora().isBlank()
                ? volume.editora() : externa.editora();
        if (nomeEditora == null || nomeEditora.isBlank()) {
            throw new RegraNegocioException("A Comic Vine não informou a editora desta edição.");
        }
        Editora editora = editoraRepository.buscarPorNome(nomeEditora).orElseGet(() -> {
            Editora nova = new Editora();
            nova.setNome(nomeEditora.trim());
            nova.setFonteExterna("COMICVINE");
            nova.setIdExterno("publisher:" + normalizar(nomeEditora));
            editoraRepository.persist(nova);
            return nova;
        });
        String tituloSerie = externa.nomeVolume() == null || externa.nomeVolume().isBlank()
                ? volume.titulo() : externa.nomeVolume().trim();
        Serie serie = serieRepository.buscarTodasPorTituloEEditoraEVolume(tituloSerie, editora.getId(), null).stream()
                .filter(item -> item.getTipoSerie() == TipoSerie.ESTRANGEIRA)
                .findFirst()
                .orElseGet(() -> {
                    Serie nova = new Serie();
                    nova.setTitulo(tituloSerie);
                    nova.setAnoInicio(dto.anoSerie());
                    nova.setTipoSerie(TipoSerie.ESTRANGEIRA);
                    nova.setEditora(editora);
                    nova.setFonteExterna("COMICVINE");
                    nova.setIdExterno(externa.idVolume() == null ? volume.idExterno() : externa.idVolume());
                    nova.setUrlOrigem(volume.urlOrigem());
                    serieRepository.persist(nova);
                    return nova;
                });
        return edicaoRepository.buscarPorNumeroESerie(dto.numero(), serie.getId()).orElseGet(() -> {
            Edicao nova = new Edicao();
            nova.setSerie(serie);
            nova.setNumero(dto.numero());
            nova.setTitulo(externa.titulo());
            nova.setNomeVolume(externa.nomeVolume());
            nova.setDescricao(externa.descricaoPortugues());
            nova.setDescricaoOriginal(externa.descricaoOriginal());
            nova.setDescricaoPortugues(externa.descricaoPortugues());
            nova.setDataCobertura(data(externa.dataCapa()));
            nova.setDataDisponibilidadeLoja(data(externa.dataVenda()));
            nova.setDataPublicacao(nova.getDataCobertura() != null ? nova.getDataCobertura() : nova.getDataDisponibilidadeLoja());
            nova.setUrlCapa(externa.urlImagem());
            nova.setFonteExterna("COMICVINE");
            nova.setIdExterno(externa.idExterno());
            nova.setIdComicVine(externa.idExterno());
            nova.setUrlComicVine(externa.urlOrigem());
            nova.setUrlOrigem(externa.urlOrigem());
            edicaoRepository.persist(nova);
            return nova;
        });
    }

    private CandidatoEdicaoOriginalPaniniDTO paraCandidato(Edicao edicao) {
        return new CandidatoEdicaoOriginalPaniniDTO(
                edicao.getId(), edicao.getSerie().getTitulo(), edicao.getNumero(),
                edicao.getSerie().getAnoInicio(), edicao.getSerie().getEditora().getNome(), edicao.getUrlCapa());
    }

    private java.time.LocalDate data(String valor) {
        try {
            return valor == null || valor.isBlank() ? null : java.time.LocalDate.parse(valor);
        } catch (java.time.format.DateTimeParseException excecao) {
            return null;
        }
    }

    private String carregarPagina(URI uri) {
        URI atual = uri;
        try {
            for (int redirecionamentos = 0; redirecionamentos <= 3; redirecionamentos++) {
                HttpRequest requisicao = HttpRequest.newBuilder(atual)
                        .timeout(Duration.ofSeconds(20))
                        .header("User-Agent", "Mozilla/5.0 (compatible; ColecionaHQ/1.0)")
                        .header("Accept", "text/html,application/xhtml+xml")
                        .GET()
                        .build();
                HttpResponse<String> resposta = httpClient.send(requisicao,
                        HttpResponse.BodyHandlers.ofString(java.nio.charset.StandardCharsets.UTF_8));
                if (resposta.statusCode() >= 300 && resposta.statusCode() < 400) {
                    String destino = resposta.headers().firstValue("location")
                            .orElseThrow(() -> new RegraNegocioException("Redirecionamento inválido retornado pela Panini."));
                    atual = validarUrlPanini(atual.resolve(destino).toString());
                    continue;
                }
                if (resposta.statusCode() < 200 || resposta.statusCode() >= 300) {
                    throw new RegraNegocioException("A Panini respondeu com status " + resposta.statusCode() + ".");
                }
                return resposta.body();
            }
            throw new RegraNegocioException("A página da Panini redirecionou muitas vezes.");
        } catch (InterruptedException excecao) {
            Thread.currentThread().interrupt();
            throw new RegraNegocioException("A consulta à Panini foi interrompida.");
        } catch (java.io.IOException excecao) {
            throw new RegraNegocioException("Não foi possível consultar a página da Panini.");
        }
    }

    private URI validarUrlPanini(String url) {
        try {
            URI uri = URI.create(url == null ? "" : url.trim());
            String host = uri.getHost() == null ? "" : uri.getHost().toLowerCase(Locale.ROOT);
            boolean hostPermitido = host.equals("panini.com.br") || host.equals("www.panini.com.br");
            if (!"https".equalsIgnoreCase(uri.getScheme()) || !hostPermitido || uri.getUserInfo() != null
                    || (uri.getPort() != -1 && uri.getPort() != 443)) {
                throw new RegraNegocioException("Informe uma URL HTTPS válida do domínio panini.com.br.");
            }
            return uri;
        } catch (IllegalArgumentException excecao) {
            throw new RegraNegocioException("Informe uma URL HTTPS válida do domínio panini.com.br.");
        }
    }

    private Edicao buscarEdicao(Long id) {
        return edicaoRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Edição não encontrada: " + id));
    }

    private String normalizar(String valor) {
        return Normalizer.normalize(valor == null ? "" : valor, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replaceAll("[^a-zA-Z0-9]", "")
                .toLowerCase(Locale.ROOT);
    }

    private String normalizarSerie(String valor) {
        return normalizar(valor == null ? null : valor.replaceFirst("(?i)^the\\s+", ""));
    }

    private record ResolucaoComicVine(
            EdicaoComicVineRespostaDTO edicao,
            VolumeComicVineRespostaDTO volume) {
    }

    private record GrupoSerie(String serieNormalizada, Integer anoSerie) {
    }

    private record ResolucaoReferenciaLote(ResolucaoComicVine resolucao, String erro) {
    }
}
