package br.com.hqhub.service;

import java.text.Normalizer;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Comparator;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import br.com.hqhub.dto.AtualizacaoHistoriaDTO;
import br.com.hqhub.dto.AtualizacaoConteudoEdicaoDTO;
import br.com.hqhub.dto.CadastroConteudoEdicaoDTO;
import br.com.hqhub.dto.CadastroHistoriaDTO;
import br.com.hqhub.dto.CadastroHistoriasLoteDTO;
import br.com.hqhub.dto.CadastroPublicacaoHistoriaDTO;
import br.com.hqhub.dto.ConteudoEdicaoRespostaDTO;
import br.com.hqhub.dto.CruzamentoEdicaoRespostaDTO;
import br.com.hqhub.dto.HistoriaRespostaDTO;
import br.com.hqhub.dto.ItemHistoriaLoteDTO;
import br.com.hqhub.dto.PublicacaoHistoriaRespostaDTO;
import br.com.hqhub.dto.EdicaoOriginalPublicacoesBrasilDTO;
import br.com.hqhub.dto.HistoriaPublicacaoBrasilDTO;
import br.com.hqhub.dto.PublicacaoBrasileiraResumoDTO;
import br.com.hqhub.dto.PublicacoesBrasileirasEdicaoOriginalDTO;
import br.com.hqhub.dto.ProgressoColecoesOriginalDTO;
import br.com.hqhub.dto.SugestaoPublicacaoHistoriaDTO;
import br.com.hqhub.entity.ConteudoEdicao;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.Historia;
import br.com.hqhub.entity.PublicacaoHistoria;
import br.com.hqhub.entity.PublicacaoRelacionada;
import br.com.hqhub.entity.TipoSerie;
import br.com.hqhub.entity.StatusPublicacaoHistoria;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.ConteudoEdicaoMapper;
import br.com.hqhub.mapper.EdicaoMapper;
import br.com.hqhub.mapper.HistoriaMapper;
import br.com.hqhub.mapper.PublicacaoHistoriaMapper;
import br.com.hqhub.repository.ConteudoEdicaoRepository;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.HistoriaRepository;
import br.com.hqhub.repository.ItemColecaoRepository;
import br.com.hqhub.repository.PublicacaoHistoriaRepository;
import br.com.hqhub.repository.PublicacaoRelacionadaRepository;
import br.com.hqhub.repository.PublicacaoHistoriaRepository.MarcoColecaoOriginal;
import io.quarkus.panache.common.Sort;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class HistoriaService {

    private final HistoriaRepository historiaRepository;
    private final EdicaoRepository edicaoRepository;
    private final ConteudoEdicaoRepository conteudoEdicaoRepository;
    private final PublicacaoHistoriaRepository publicacaoHistoriaRepository;
    private final PublicacaoRelacionadaRepository publicacaoRelacionadaRepository;
    private final HistoriaMapper historiaMapper;
    private final ConteudoEdicaoMapper conteudoEdicaoMapper;
    private final PublicacaoHistoriaMapper publicacaoHistoriaMapper;
    private final EdicaoMapper edicaoMapper;
    private final ItemColecaoRepository itemColecaoRepository;
    private final UsuarioAutenticadoService usuarioAutenticadoService;

    public HistoriaService(
            HistoriaRepository historiaRepository,
            EdicaoRepository edicaoRepository,
            ConteudoEdicaoRepository conteudoEdicaoRepository,
            PublicacaoHistoriaRepository publicacaoHistoriaRepository,
            PublicacaoRelacionadaRepository publicacaoRelacionadaRepository,
            HistoriaMapper historiaMapper,
            ConteudoEdicaoMapper conteudoEdicaoMapper,
            PublicacaoHistoriaMapper publicacaoHistoriaMapper,
            EdicaoMapper edicaoMapper,
            ItemColecaoRepository itemColecaoRepository,
            UsuarioAutenticadoService usuarioAutenticadoService) {
        this.historiaRepository = historiaRepository;
        this.edicaoRepository = edicaoRepository;
        this.conteudoEdicaoRepository = conteudoEdicaoRepository;
        this.publicacaoHistoriaRepository = publicacaoHistoriaRepository;
        this.publicacaoRelacionadaRepository = publicacaoRelacionadaRepository;
        this.historiaMapper = historiaMapper;
        this.conteudoEdicaoMapper = conteudoEdicaoMapper;
        this.publicacaoHistoriaMapper = publicacaoHistoriaMapper;
        this.edicaoMapper = edicaoMapper;
        this.itemColecaoRepository = itemColecaoRepository;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
    }

    @Transactional
    public HistoriaRespostaDTO cadastrarHistoria(CadastroHistoriaDTO dto) {
        validarOrigemExterna(dto.fonteExterna(), dto.idExterno());

        if (historiaRepository.existePorOrigemExterna(dto.fonteExterna(), dto.idExterno())) {
            throw new RegraNegocioException("Já existe uma história cadastrada com esta origem externa.");
        }

        Historia historia = historiaMapper.paraEntidade(dto);
        historiaRepository.persist(historia);
        return historiaMapper.paraResposta(historia);
    }

    @Transactional
    public List<ConteudoEdicaoRespostaDTO> cadastrarHistoriasEmLote(
            Long edicaoId,
            CadastroHistoriasLoteDTO dto) {
        Edicao edicao = buscarEdicaoPorId(edicaoId);
        List<ConteudoEdicao> conteudosExistentes = conteudoEdicaoRepository.listarPorEdicao(edicaoId);
        Set<Integer> ordensOcupadas = conteudosExistentes.stream()
                .map(ConteudoEdicao::getOrdem)
                .collect(Collectors.toCollection(HashSet::new));
        Set<String> titulosOcupados = conteudosExistentes.stream()
                .map(this::tituloDoConteudo)
                .map(this::normalizarTitulo)
                .filter(titulo -> !titulo.isBlank())
                .collect(Collectors.toCollection(HashSet::new));

        int proximaOrdem = conteudosExistentes.stream()
                .map(ConteudoEdicao::getOrdem)
                .max(Integer::compareTo)
                .orElse(0) + 1;
        List<Integer> ordens = new java.util.ArrayList<>(dto.historias().size());

        for (ItemHistoriaLoteDTO item : dto.historias()) {
            int ordem = item.ordem() == null ? proximaOrdem : item.ordem();
            while (item.ordem() == null && ordensOcupadas.contains(ordem)) {
                ordem++;
            }
            proximaOrdem = Math.max(proximaOrdem, ordem + 1);

            if (!ordensOcupadas.add(ordem)) {
                throw new RegraNegocioException("A ordem " + ordem + " já está ocupada nesta edição.");
            }

            String tituloNormalizado = normalizarTitulo(item.titulo());
            if (!titulosOcupados.add(tituloNormalizado)) {
                throw new RegraNegocioException(
                        "A história ‘" + item.titulo().trim() + "’ já está cadastrada nesta edição ou repetida no lote.");
            }
            ordens.add(ordem);
        }

        List<ConteudoEdicaoRespostaDTO> respostas = new java.util.ArrayList<>(dto.historias().size());
        for (int indice = 0; indice < dto.historias().size(); indice++) {
            ItemHistoriaLoteDTO item = dto.historias().get(indice);
            String titulo = item.titulo().trim();
            CadastroHistoriaDTO historiaDTO = new CadastroHistoriaDTO(
                    titulo,
                    textoOuNull(item.tituloOriginal()),
                    textoOuNull(item.resumo()),
                    item.quantidadePaginas(),
                    item.tipo(),
                    null,
                    null,
                    textoOuNull(dto.urlFonte()));
            Historia historia = historiaMapper.paraEntidade(historiaDTO);
            historiaRepository.persist(historia);

            CadastroConteudoEdicaoDTO conteudoDTO = new CadastroConteudoEdicaoDTO(
                    edicaoId,
                    historia.getId(),
                    ordens.get(indice),
                    titulo,
                    null,
                    null,
                    item.quantidadePaginas(),
                    item.tipo(),
                    textoOuNull(item.resumo()));
            ConteudoEdicao conteudo = conteudoEdicaoMapper.paraEntidade(conteudoDTO, edicao, historia);
            conteudoEdicaoRepository.persist(conteudo);
            respostas.add(conteudoEdicaoMapper.paraResposta(conteudo));
        }
        return respostas;
    }

    @Transactional
    public HistoriaRespostaDTO atualizarHistoria(Long id, AtualizacaoHistoriaDTO dto) {
        Historia historia = buscarHistoriaPorId(id);
        historiaMapper.atualizarEntidade(historia, dto);
        return historiaMapper.paraResposta(historia);
    }

    public HistoriaRespostaDTO buscarHistoriaPorIdResposta(Long id) {
        return historiaMapper.paraResposta(buscarHistoriaPorId(id));
    }

    public List<HistoriaRespostaDTO> listarHistorias() {
        return historiaRepository.listAll(Sort.by("titulo"))
                .stream()
                .map(historiaMapper::paraResposta)
                .toList();
    }

    @Transactional
    public ConteudoEdicaoRespostaDTO adicionarConteudo(CadastroConteudoEdicaoDTO dto) {
        Edicao edicao = buscarEdicaoPorId(dto.edicaoId());
        Historia historia = buscarHistoriaPorId(dto.historiaId());

        if (conteudoEdicaoRepository.existePorEdicaoEOrdem(dto.edicaoId(), dto.ordem())) {
            throw new RegraNegocioException("Já existe conteúdo cadastrado nesta ordem para esta edição.");
        }

        ConteudoEdicao conteudo = conteudoEdicaoMapper.paraEntidade(dto, edicao, historia);
        conteudoEdicaoRepository.persist(conteudo);
        return conteudoEdicaoMapper.paraResposta(conteudo);
    }

    @Transactional
    public List<ConteudoEdicaoRespostaDTO> listarConteudosPorEdicao(Long edicaoId) {
        buscarEdicaoPorId(edicaoId);
        return conteudoEdicaoRepository.listarPorEdicao(edicaoId)
                .stream()
                .map(conteudoEdicaoMapper::paraResposta)
                .toList();
    }

    @Transactional
    public ConteudoEdicaoRespostaDTO atualizarConteudo(Long id, AtualizacaoConteudoEdicaoDTO dto) {
        ConteudoEdicao conteudo = conteudoEdicaoRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Conteúdo da edição não encontrado."));

        if (conteudoEdicaoRepository.existePorEdicaoEOrdemEmOutroConteudo(
                conteudo.getEdicao().getId(),
                dto.ordem(),
                id)) {
            throw new RegraNegocioException("Já existe conteúdo cadastrado nesta ordem para esta edição.");
        }

        conteudoEdicaoMapper.atualizarEntidade(conteudo, dto);
        return conteudoEdicaoMapper.paraResposta(conteudo);
    }

    @Transactional
    public PublicacaoHistoriaRespostaDTO cadastrarPublicacao(CadastroPublicacaoHistoriaDTO dto) {
        if (dto.edicaoOriginalId().equals(dto.edicaoPublicadaId())) {
            throw new RegraNegocioException("Edição original e edição publicada devem ser diferentes.");
        }

        Historia historia = buscarHistoriaPorId(dto.historiaId());
        Edicao original = buscarEdicaoPorId(dto.edicaoOriginalId());
        Edicao publicada = buscarEdicaoPorId(dto.edicaoPublicadaId());

        if (publicacaoHistoriaRepository.existePorHistoriaEEdicaoPublicada(dto.historiaId(), dto.edicaoPublicadaId())) {
            throw new RegraNegocioException("Esta história já está vinculada a esta edição publicada.");
        }

        PublicacaoHistoria publicacao = publicacaoHistoriaMapper.paraEntidade(dto, historia, original, publicada);
        publicacaoHistoriaRepository.persist(publicacao);
        return publicacaoHistoriaMapper.paraResposta(publicacao);
    }

    @Transactional
    public PublicacaoHistoriaRespostaDTO sugerirPublicacao(Long historiaId, SugestaoPublicacaoHistoriaDTO dto) {
        Historia historia = buscarHistoriaPorId(historiaId);
        Edicao publicada = buscarEdicaoPorId(dto.edicaoId());
        ConteudoEdicao conteudoOriginal = conteudoEdicaoRepository.buscarPrimeiroPorHistoria(historiaId)
                .orElseThrow(() -> new RegraNegocioException(
                        "Cadastre primeiro em qual edição a história aparece originalmente."));
        Edicao original = conteudoOriginal.getEdicao();

        if (original.getId().equals(publicada.getId())) {
            throw new RegraNegocioException("A edição publicada deve ser diferente da edição original.");
        }

        if (publicacaoHistoriaRepository.existePorHistoriaEEdicaoPublicada(historiaId, dto.edicaoId())) {
            throw new RegraNegocioException("Esta história já está vinculada a esta edição publicada.");
        }

        PublicacaoHistoria publicacao = new PublicacaoHistoria();
        publicacao.setHistoria(historia);
        publicacao.setEdicaoOriginal(original);
        publicacao.setEdicaoPublicada(publicada);
        publicacao.setStatus(StatusPublicacaoHistoria.DESCONHECIDA);
        publicacao.setTipoPublicacaoHistoria(dto.tipoPublicacaoHistoria());
        publicacao.setFonteInformacao(dto.fonteInformacao());
        publicacao.setUrlFonteInformacao(dto.urlFonteInformacao());
        publicacao.setFonteExterna(dto.fonteInformacao());
        publicacao.setUrlOrigem(dto.urlFonteInformacao());
        publicacao.setObservacoes(dto.observacao());
        // TODO: vincular usuarioCriador ao usuário autenticado quando a moderação de contribuições for consolidada.
        publicacaoHistoriaRepository.persist(publicacao);

        return publicacaoHistoriaMapper.paraResposta(publicacao);
    }

    @Transactional
    public List<PublicacaoHistoriaRespostaDTO> listarPublicacoesPorHistoria(Long historiaId) {
        buscarHistoriaPorId(historiaId);
        return publicacaoHistoriaRepository.listarPorHistoria(historiaId)
                .stream()
                .map(publicacaoHistoriaMapper::paraResposta)
                .toList();
    }

    @Transactional
    public List<PublicacaoHistoriaRespostaDTO> listarPublicacoesPorEdicaoPublicada(Long edicaoPublicadaId) {
        buscarEdicaoPorId(edicaoPublicadaId);
        return publicacaoHistoriaRepository.listarPorEdicaoPublicada(edicaoPublicadaId)
                .stream()
                .map(publicacaoHistoriaMapper::paraResposta)
                .toList();
    }

    @Transactional
    public List<PublicacaoHistoriaRespostaDTO> listarPublicacoesPorEdicaoOriginal(Long edicaoOriginalId) {
        Edicao original = edicaoRepository.resolverOriginalComVinculos(buscarEdicaoPorId(edicaoOriginalId));
        return edicaoRepository.listarIdsOriginaisCorrespondentes(original).stream()
                .flatMap(id -> publicacaoHistoriaRepository.listarPorEdicaoOriginal(id).stream())
                .map(publicacaoHistoriaMapper::paraResposta)
                .toList();
    }

    @Transactional
    public PublicacoesBrasileirasEdicaoOriginalDTO listarPublicacoesBrasileiras(Long edicaoOriginalId) {
        return listarPublicacoesBrasileiras(edicaoOriginalId, usuarioAutenticadoService.obterUsuario().getId());
    }

    @Transactional
    public PublicacoesBrasileirasEdicaoOriginalDTO listarPublicacoesBrasileirasPublicas(Long edicaoOriginalId) {
        return listarPublicacoesBrasileiras(edicaoOriginalId, null);
    }

    @Transactional
    public PublicacoesBrasileirasEdicaoOriginalDTO listarPublicacoesComicVine(
            String idEdicao, String idVolume, String numero) {
        return edicaoRepository.buscarCorrespondenteComicVine(idEdicao, idVolume, numero)
                .map(edicao -> listarPublicacoesBrasileiras(edicao.getId(), null))
                .orElse(null);
    }

    @Transactional
    public ProgressoColecoesOriginalDTO calcularProgressoColecoesComicVine(
            String idVolume,
            String numeroAlvo) {
        Double alvo = numeroInicial(numeroAlvo);
        if (idVolume == null || idVolume.isBlank() || alvo == null) {
            return new ProgressoColecoesOriginalDTO(idVolume, numeroAlvo, alvo, List.of());
        }

        Map<Long, List<MarcoColecaoOriginal>> porColecao = publicacaoHistoriaRepository
                .listarMarcosColecoesPorVolumeComicVine(idVolume).stream()
                .collect(Collectors.groupingBy(
                        MarcoColecaoOriginal::serieId,
                        LinkedHashMap::new,
                        Collectors.toList()));

        List<ProgressoColecoesOriginalDTO.Colecao> colecoes = porColecao.values().stream()
                .map(marcos -> resumirProgressoColecao(marcos, alvo))
                .sorted(Comparator
                        .comparing(ProgressoColecoesOriginalDTO.Colecao::alvoPublicado).reversed()
                        .thenComparing(ProgressoColecoesOriginalDTO.Colecao::ultimaEdicaoOriginalNumerica,
                                Comparator.nullsLast(Comparator.reverseOrder()))
                        .thenComparing(ProgressoColecoesOriginalDTO.Colecao::titulo,
                                String.CASE_INSENSITIVE_ORDER))
                .toList();

        return new ProgressoColecoesOriginalDTO(idVolume, numeroAlvo, alvo, colecoes);
    }

    private ProgressoColecoesOriginalDTO.Colecao resumirProgressoColecao(
            List<MarcoColecaoOriginal> marcos,
            double alvo) {
        MarcoColecaoOriginal identidade = marcos.getFirst();
        MarcoColecaoOriginal maiorOriginal = marcos.stream()
                .max(Comparator.comparingDouble(MarcoColecaoOriginal::edicaoOriginalNumerica))
                .orElse(identidade);
        MarcoColecaoOriginal edicaoDoMarcoAtual = marcos.stream()
                .filter(marco -> Math.abs(marco.edicaoOriginalNumerica()
                        - maiorOriginal.edicaoOriginalNumerica()) < 0.001)
                .max(Comparator
                        .comparing(MarcoColecaoOriginal::dataPublicacaoBrasileira,
                                Comparator.nullsFirst(Comparator.naturalOrder()))
                        .thenComparing(MarcoColecaoOriginal::edicaoBrasileiraId))
                .orElse(identidade);

        Set<Long> edicoesBrasileiras = marcos.stream()
                .map(MarcoColecaoOriginal::edicaoBrasileiraId)
                .collect(Collectors.toSet());
        Set<Double> edicoesOriginais = marcos.stream()
                .map(MarcoColecaoOriginal::edicaoOriginalNumerica)
                .collect(Collectors.toSet());
        List<LocalDate> datas = marcos.stream()
                .map(MarcoColecaoOriginal::dataPublicacaoBrasileira)
                .filter(java.util.Objects::nonNull)
                .distinct()
                .sorted()
                .toList();

        double mediaOriginais = edicoesBrasileiras.isEmpty()
                ? 0
                : arredondar((double) edicoesOriginais.size() / edicoesBrasileiras.size(), 2);
        Double periodicidade = periodicidadeMediaMeses(datas);
        double atual = maiorOriginal.edicaoOriginalNumerica();
        boolean alvoPublicado = edicoesOriginais.stream().anyMatch(numero -> Math.abs(numero - alvo) < 0.001);
        boolean ultrapassou = atual > alvo && !alvoPublicado;
        int faltam = alvo > atual ? (int) Math.ceil(alvo - atual) : 0;
        Integer volumesEstimados = faltam > 0 && mediaOriginais > 0
                ? (int) Math.ceil(faltam / mediaOriginais)
                : 0;
        LocalDate previsao = null;
        LocalDate ultimaDataColecao = datas.isEmpty() ? null : datas.getLast();
        if (volumesEstimados > 0 && periodicidade != null && ultimaDataColecao != null) {
            LocalDate base = ultimaDataColecao.isAfter(LocalDate.now())
                    ? ultimaDataColecao
                    : LocalDate.now();
            previsao = base.plusDays(Math.round(volumesEstimados * periodicidade * 30.4375));
        }

        String confianca = datas.size() >= 5 && edicoesBrasileiras.size() >= 8
                ? "ALTA"
                : datas.size() >= 3 && edicoesBrasileiras.size() >= 4 ? "MEDIA" : "BAIXA";

        return new ProgressoColecoesOriginalDTO.Colecao(
                identidade.serieId(), identidade.titulo(), identidade.volume(), identidade.editora(),
                edicaoDoMarcoAtual.edicaoBrasileiraId(), edicaoDoMarcoAtual.edicaoBrasileiraNumero(),
                edicaoDoMarcoAtual.dataPublicacaoBrasileira(), maiorOriginal.edicaoOriginalNumero(), atual,
                edicoesBrasileiras.size(), edicoesOriginais.size(), mediaOriginais, periodicidade,
                alvoPublicado, ultrapassou, faltam, volumesEstimados, previsao, confianca);
    }

    private Double periodicidadeMediaMeses(List<LocalDate> datas) {
        if (datas.size() < 2) return null;
        long dias = 0;
        for (int indice = 1; indice < datas.size(); indice++) {
            dias += ChronoUnit.DAYS.between(datas.get(indice - 1), datas.get(indice));
        }
        return arredondar((dias / (double) (datas.size() - 1)) / 30.4375, 1);
    }

    private Double numeroInicial(String numero) {
        if (numero == null) return null;
        var correspondencia = java.util.regex.Pattern.compile("^(\\d+)").matcher(numero.trim());
        return correspondencia.find() ? Double.valueOf(correspondencia.group(1)) : null;
    }

    private double arredondar(double valor, int casas) {
        double fator = Math.pow(10, casas);
        return Math.round(valor * fator) / fator;
    }

    private PublicacoesBrasileirasEdicaoOriginalDTO listarPublicacoesBrasileiras(
            Long edicaoOriginalId,
            Long usuarioId) {
        Edicao original = edicaoRepository.resolverOriginalComVinculos(buscarEdicaoPorId(edicaoOriginalId));
        List<Long> idsOriginais = edicaoRepository.listarIdsOriginaisCorrespondentes(original);
        List<PublicacaoHistoria> vinculos = publicacaoHistoriaRepository
                .listarPublicacoesBrasileirasComDados(idsOriginais);
        List<PublicacaoRelacionada> vinculosEditoriais = publicacaoRelacionadaRepository
                .listarPublicacoesBrasileiras(idsOriginais).stream()
                .filter(vinculo -> vinculo.getEdicaoDestino().getSerie().getTipoSerie() == TipoSerie.BRASILEIRA)
                .toList();
        List<ConteudoEdicao> conteudosOriginais = conteudoEdicaoRepository
                .listarPorEdicaoComHistoria(original.getId());

        Map<Long, List<PublicacaoHistoria>> porEdicao = vinculos.stream()
                .collect(Collectors.groupingBy(
                        publicacao -> publicacao.getEdicaoPublicada().getId(),
                        LinkedHashMap::new,
                        Collectors.toList()));
        Map<Long, Edicao> edicoesPublicadas = new LinkedHashMap<>();
        vinculos.forEach(vinculo -> edicoesPublicadas.put(
                vinculo.getEdicaoPublicada().getId(), vinculo.getEdicaoPublicada()));
        vinculosEditoriais.forEach(vinculo -> edicoesPublicadas.putIfAbsent(
                vinculo.getEdicaoDestino().getId(), vinculo.getEdicaoDestino()));
        Set<Long> idsEdicoes = edicoesPublicadas.keySet();
        Set<Long> idsNaEstante = usuarioId == null || idsEdicoes.isEmpty()
                ? Set.of()
                : itemColecaoRepository.listarPorUsuarioEEdicoes(usuarioId, idsEdicoes).stream()
                        .map(item -> item.getEdicao().getId())
                        .collect(Collectors.toSet());
        Set<Long> idsHistoriasOriginais = conteudosOriginais.stream()
                .map(conteudo -> conteudo.getHistoria().getId())
                .collect(Collectors.toSet());
        boolean permiteCalcularCompletude = !idsHistoriasOriginais.isEmpty();

        List<Edicao> edicoesOrdenadas = edicoesPublicadas.values().stream()
                .sorted(Comparator.comparing(this::dataDaEdicao,
                        Comparator.nullsLast(Comparator.naturalOrder())))
                .toList();

        List<PublicacaoBrasileiraResumoDTO> publicacoes = new java.util.ArrayList<>();
        for (int indice = 0; indice < edicoesOrdenadas.size(); indice++) {
            Edicao publicada = edicoesOrdenadas.get(indice);
            List<PublicacaoHistoria> grupo = porEdicao.getOrDefault(publicada.getId(), List.of());
            Set<Long> presentes = grupo.stream()
                    .map(publicacao -> publicacao.getHistoria().getId())
                    .collect(Collectors.toSet());
            List<HistoriaPublicacaoBrasilDTO> historias = grupo.isEmpty()
                    ? List.of()
                    : permiteCalcularCompletude
                    ? conteudosOriginais.stream()
                            .map(conteudo -> new HistoriaPublicacaoBrasilDTO(
                                    conteudo.getHistoria().getId(),
                                    conteudo.getHistoria().getTitulo(),
                                    presentes.contains(conteudo.getHistoria().getId())))
                            .toList()
                    : grupo.stream()
                            .map(PublicacaoHistoria::getHistoria)
                            .distinct()
                            .map(historia -> new HistoriaPublicacaoBrasilDTO(
                                    historia.getId(), historia.getTitulo(), true))
                            .toList();
            Boolean completa = grupo.isEmpty()
                    ? null
                    : permiteCalcularCompletude
                    ? presentes.containsAll(idsHistoriasOriginais)
                    : null;
            if (Boolean.TRUE.equals(completa)
                    && grupo.stream().anyMatch(p -> p.getStatus() != StatusPublicacaoHistoria.COMPLETA)) {
                completa = null; // Presença de histórias não comprova ausência de cortes/adaptações.
            }
            publicacoes.add(new PublicacaoBrasileiraResumoDTO(
                    publicada.getId(), tituloDaEdicao(publicada), publicada.getNumero(),
                    publicada.getSerie().getVolume(), publicada.getSerie().getEditora().getNome(),
                    anoDaEdicao(publicada), publicada.getSerie().getTitulo(), publicada.getUrlCapa(),
                    indice == 0, completa, idsNaEstante.contains(publicada.getId()), presentes.size(), historias));
        }

        EdicaoOriginalPublicacoesBrasilDTO resumoOriginal = new EdicaoOriginalPublicacoesBrasilDTO(
                original.getId(), tituloDaEdicao(original), original.getNumero(), original.getSerie().getVolume(),
                original.getSerie().getEditora().getNome(), anoDaEdicao(original),
                original.getSerie().getEditora().getPaisOrigem(), original.getUrlCapa());
        return new PublicacoesBrasileirasEdicaoOriginalDTO(
                resumoOriginal, publicacoes.size(), conteudosOriginais.size(), publicacoes);
    }

    private String tituloDaEdicao(Edicao edicao) {
        return edicao.getTitulo() == null || edicao.getTitulo().isBlank()
                ? edicao.getSerie().getTitulo()
                : edicao.getTitulo();
    }

    private LocalDate dataDaEdicao(Edicao edicao) {
        return edicao.getDataPublicacao() != null ? edicao.getDataPublicacao() : edicao.getDataCobertura();
    }

    private Integer anoDaEdicao(Edicao edicao) {
        LocalDate data = dataDaEdicao(edicao);
        return data != null ? data.getYear() : edicao.getSerie().getAnoInicio();
    }

    @Transactional
    public CruzamentoEdicaoRespostaDTO cruzarEdicoes(Long edicaoOriginalId, Long edicaoComparadaId) {
        Edicao original = buscarEdicaoPorId(edicaoOriginalId);
        Edicao comparada = buscarEdicaoPorId(edicaoComparadaId);
        List<ConteudoEdicao> conteudosOriginais = conteudoEdicaoRepository.listarPorEdicao(edicaoOriginalId);
        List<PublicacaoHistoria> publicacoes = publicacaoHistoriaRepository
                .listarPorEdicaoOriginalEPublicada(edicaoOriginalId, edicaoComparadaId);

        Set<Long> idsHistoriasIncluidas = publicacoes.stream()
                .map(publicacao -> publicacao.getHistoria().getId())
                .collect(Collectors.toSet());

        List<ConteudoEdicaoRespostaDTO> conteudosFora = conteudosOriginais.stream()
                .filter(conteudo -> !idsHistoriasIncluidas.contains(conteudo.getHistoria().getId()))
                .map(conteudoEdicaoMapper::paraResposta)
                .toList();

        List<ConteudoEdicaoRespostaDTO> conteudosOriginaisResposta = conteudosOriginais.stream()
                .map(conteudoEdicaoMapper::paraResposta)
                .toList();

        List<PublicacaoHistoriaRespostaDTO> historiasIncluidas = publicacoes.stream()
                .map(publicacaoHistoriaMapper::paraResposta)
                .toList();

        return new CruzamentoEdicaoRespostaDTO(
                edicaoMapper.paraResposta(original),
                edicaoMapper.paraResposta(comparada),
                conteudosOriginaisResposta,
                historiasIncluidas,
                conteudosFora,
                conteudosOriginaisResposta.size(),
                historiasIncluidas.size(),
                conteudosFora.size());
    }

    @Transactional
    public void removerConteudo(Long id) {
        ConteudoEdicao conteudo = conteudoEdicaoRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Conteúdo da edição não encontrado."));
        conteudoEdicaoRepository.delete(conteudo);
    }

    @Transactional
    public void removerPublicacao(Long id) {
        PublicacaoHistoria publicacao = publicacaoHistoriaRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Publicação da história não encontrada."));
        publicacaoHistoriaRepository.delete(publicacao);
    }

    private Historia buscarHistoriaPorId(Long id) {
        return historiaRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("História não encontrada."));
    }

    private Edicao buscarEdicaoPorId(Long id) {
        return edicaoRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Edição não encontrada."));
    }

    private void validarOrigemExterna(String fonteExterna, String idExterno) {
        if ((fonteExterna == null) != (idExterno == null)) {
            throw new RegraNegocioException("Fonte externa e id externo devem ser informados juntos.");
        }
    }

    private String tituloDoConteudo(ConteudoEdicao conteudo) {
        if (conteudo.getTituloUsado() != null && !conteudo.getTituloUsado().isBlank()) {
            return conteudo.getTituloUsado();
        }
        Historia historia = conteudo.getHistoria();
        if (historia.getTituloPortugues() != null && !historia.getTituloPortugues().isBlank()) {
            return historia.getTituloPortugues();
        }
        return historia.getTitulo();
    }

    private String normalizarTitulo(String titulo) {
        return Normalizer.normalize(titulo.trim().toLowerCase(Locale.ROOT), Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replaceAll("[^a-z0-9]+", " ")
                .trim();
    }

    private String textoOuNull(String texto) {
        return texto == null || texto.isBlank() ? null : texto.trim();
    }
}
