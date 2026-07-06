package br.com.hqhub.service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HexFormat;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import java.util.Optional;

import br.com.hqhub.dto.EdicaoImportacaoDTO;
import br.com.hqhub.dto.EdicaoComicVineRespostaDTO;
import br.com.hqhub.dto.HistoriaImportacaoDTO;
import br.com.hqhub.dto.ImportacaoCatalogoDTO;
import br.com.hqhub.dto.PublicacaoOriginalImportacaoDTO;
import br.com.hqhub.dto.ResultadoImportacaoCatalogoDTO;
import br.com.hqhub.dto.SerieBrasileiraImportacaoDTO;
import br.com.hqhub.entity.ConteudoEdicao;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.Editora;
import br.com.hqhub.entity.Historia;
import br.com.hqhub.entity.LinkEdicao;
import br.com.hqhub.entity.PostagemFeed;
import br.com.hqhub.entity.PublicacaoHistoria;
import br.com.hqhub.entity.Serie;
import br.com.hqhub.entity.StatusPublicacaoHistoria;
import br.com.hqhub.entity.StatusValidacao;
import br.com.hqhub.entity.TipoConteudoEdicao;
import br.com.hqhub.entity.TipoLinkEdicao;
import br.com.hqhub.entity.TipoPublicacaoHistoria;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.repository.ConteudoEdicaoRepository;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.EditoraRepository;
import br.com.hqhub.repository.HistoriaRepository;
import br.com.hqhub.repository.LinkEdicaoRepository;
import br.com.hqhub.repository.PostagemFeedRepository;
import br.com.hqhub.repository.PublicacaoHistoriaRepository;
import br.com.hqhub.repository.SerieRepository;
import br.com.hqhub.util.NormalizadorTexto;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class ImportacaoCatalogoService {

    private static final String FONTE_GUIA_DOS_QUADRINHOS = "GUIA_DOS_QUADRINHOS";
    private static final int TAMANHO_MAXIMO_ID_EXTERNO = 100;
    private static final int LIMITE_AVISOS_BACKFILL = 50;

    private final EditoraRepository editoraRepository;
    private final SerieRepository serieRepository;
    private final EdicaoRepository edicaoRepository;
    private final HistoriaRepository historiaRepository;
    private final ConteudoEdicaoRepository conteudoEdicaoRepository;
    private final PublicacaoHistoriaRepository publicacaoHistoriaRepository;
    private final IntegracaoExternaService integracaoExternaService;
    private final LinkEdicaoRepository linkEdicaoRepository;
    private final PostagemFeedRepository postagemFeedRepository;
    private final UsuarioAutenticadoService usuarioAutenticadoService;

    public ImportacaoCatalogoService(
            EditoraRepository editoraRepository,
            SerieRepository serieRepository,
            EdicaoRepository edicaoRepository,
            HistoriaRepository historiaRepository,
            ConteudoEdicaoRepository conteudoEdicaoRepository,
            PublicacaoHistoriaRepository publicacaoHistoriaRepository,
            IntegracaoExternaService integracaoExternaService,
            LinkEdicaoRepository linkEdicaoRepository,
            PostagemFeedRepository postagemFeedRepository,
            UsuarioAutenticadoService usuarioAutenticadoService) {
        this.editoraRepository = editoraRepository;
        this.serieRepository = serieRepository;
        this.edicaoRepository = edicaoRepository;
        this.historiaRepository = historiaRepository;
        this.conteudoEdicaoRepository = conteudoEdicaoRepository;
        this.publicacaoHistoriaRepository = publicacaoHistoriaRepository;
        this.integracaoExternaService = integracaoExternaService;
        this.linkEdicaoRepository = linkEdicaoRepository;
        this.postagemFeedRepository = postagemFeedRepository;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
    }

    @Transactional
    public ResultadoImportacaoCatalogoDTO importar(ImportacaoCatalogoDTO dto) {
        validar(dto);

        ContadoresImportacao contadores = new ContadoresImportacao();
        List<String> avisos = new ArrayList<>();
        if (dto.avisos() != null) {
            avisos.addAll(dto.avisos());
        }

        Serie serieBrasileira = obterOuCriarSerieBrasileira(dto.serieBrasileira(), dto, contadores);

        for (EdicaoImportacaoDTO edicaoDto : dto.edicoes()) {
            Edicao edicaoBrasileira = obterOuCriarEdicaoBrasileira(serieBrasileira, edicaoDto, dto, contadores);
            importarHistorias(edicaoBrasileira, edicaoDto, dto, contadores, avisos);
        }

        publicarNovidadeNoFeed(serieBrasileira, dto, contadores, avisos);

        return new ResultadoImportacaoCatalogoDTO(
                serieBrasileira.getId(),
                serieBrasileira.getTitulo(),
                contadores.editorasCriadas,
                contadores.seriesCriadas,
                contadores.edicoesCriadas,
                contadores.edicoesAtualizadas,
                contadores.historiasCriadas,
                contadores.conteudosCriados,
                contadores.publicacoesCriadas,
                contadores.itensReaproveitados,
                avisos);
    }

    @Transactional
    public ResultadoImportacaoCatalogoDTO preencherComicVineEdicoesOriginaisGuia(Integer limite, String serie, String numero) {
        int limiteTratado = limite == null || limite <= 0 ? 10 : Math.min(limite, 50);
        List<Edicao> edicoes;
        try {
            edicoes = edicaoRepository.listarOriginaisGuiaSemComicVine(FONTE_GUIA_DOS_QUADRINHOS, limiteTratado, serie, numero);
        } catch (Throwable e) {
            return new ResultadoImportacaoCatalogoDTO(
                    null,
                    "Backfill Comic Vine",
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    List.of("Falha ao listar edicoes originais do Guia para backfill: "
                            + e.getClass().getSimpleName() + " - " + textoOuPadrao(e.getMessage(), "sem detalhes")));
        }

        int atualizadas = 0;
        int semCorrespondencia = 0;
        List<String> avisos = new ArrayList<>();

        for (Edicao edicao : edicoes) {
            try {
                if (enriquecerEdicaoOriginalComicVine(edicao)) {
                    atualizadas++;
                } else {
                    semCorrespondencia++;
                    adicionarAvisoBackfill(avisos, "Sem correspondencia segura na Comic Vine para "
                            + edicao.getSerie().getTitulo() + " #" + edicao.getNumero());
                }
            } catch (Throwable e) {
                semCorrespondencia++;
                adicionarAvisoBackfill(avisos, "Falha ao enriquecer edicao original " + edicao.getId()
                        + ": " + e.getClass().getSimpleName() + " - " + textoOuPadrao(e.getMessage(), "sem detalhes"));
            }
        }

        if (semCorrespondencia > LIMITE_AVISOS_BACKFILL && !avisos.isEmpty()) {
            avisos.set(avisos.size() - 1, "Outras " + (semCorrespondencia - avisos.size() + 1)
                    + " edicoes ficaram sem correspondencia segura.");
        }

        return new ResultadoImportacaoCatalogoDTO(
                null,
                "Backfill Comic Vine",
                0,
                0,
                0,
                atualizadas,
                0,
                0,
                0,
                semCorrespondencia,
                avisos);
    }

    private void validar(ImportacaoCatalogoDTO dto) {
        if (dto.edicoes() == null || dto.edicoes().isEmpty()) {
            throw new RegraNegocioException("JSON de importação não possui edições.");
        }
    }

    private Serie obterOuCriarSerieBrasileira(
            SerieBrasileiraImportacaoDTO dto,
            ImportacaoCatalogoDTO importacao,
            ContadoresImportacao contadores) {
        Editora editora = obterOuCriarEditora(dto.editora(), contadores);
        Optional<Serie> existente = serieRepository.buscarPorTituloEEditoraEVolume(
                dto.titulo(),
                editora.getId(),
                dto.volume());

        if (existente.isPresent()) {
            contadores.itensReaproveitados++;
            return existente.get();
        }

        Serie serie = new Serie();
        serie.setTitulo(limitar(dto.titulo(), 255));
        serie.setDescricao(dto.fase());
        serie.setVolume(dto.volume());
        serie.setEditora(editora);
        serie.setFonteExterna(FONTE_GUIA_DOS_QUADRINHOS);
        serie.setIdExterno(idSerieBrasileira(dto));
        serie.setUrlOrigem(urlOrigem(importacao));
        serieRepository.persist(serie);
        contadores.seriesCriadas++;
        return serie;
    }

    private Edicao obterOuCriarEdicaoBrasileira(
            Serie serie,
            EdicaoImportacaoDTO dto,
            ImportacaoCatalogoDTO importacao,
            ContadoresImportacao contadores) {
        Optional<Edicao> existente = edicaoRepository.buscarPorOrigemExterna(
                FONTE_GUIA_DOS_QUADRINHOS,
                idEdicaoBrasileira(serie, dto));

        if (existente.isEmpty()) {
            existente = edicaoRepository.buscarPorNumeroESerie(dto.numero(), serie.getId());
        }

        if (existente.isPresent()) {
            atualizarEdicao(existente.get(), dto, importacao);
            contadores.edicoesAtualizadas++;
            return existente.get();
        }

        Edicao edicao = new Edicao();
        edicao.setSerie(serie);
        edicao.setNumero(limitar(dto.numero(), 255));
        edicao.setFonteExterna(FONTE_GUIA_DOS_QUADRINHOS);
        edicao.setIdExterno(idEdicaoBrasileira(serie, dto));
        atualizarEdicao(edicao, dto, importacao);
        edicaoRepository.persist(edicao);
        contadores.edicoesCriadas++;
        return edicao;
    }

    private void importarHistorias(
            Edicao edicaoBrasileira,
            EdicaoImportacaoDTO edicaoDto,
            ImportacaoCatalogoDTO importacao,
            ContadoresImportacao contadores,
            List<String> avisos) {
        if (edicaoDto.historias() == null || edicaoDto.historias().isEmpty()) {
            avisos.add("Edição " + edicaoDto.numero() + " não possui histórias no JSON.");
            return;
        }

        int ordemFallback = 1;
        for (HistoriaImportacaoDTO historiaDto : edicaoDto.historias()) {
            int ordem = historiaDto.ordem() == null ? ordemFallback : historiaDto.ordem();
            ordemFallback++;

            Historia historia = obterOuCriarHistoria(historiaDto, contadores);
            criarConteudoSeNecessario(edicaoBrasileira, historia, historiaDto, ordem, contadores);

            if (historiaDto.publicacaoOriginal() == null) {
                avisos.add("História sem publicação original: " + historiaDto.tituloPortugues());
                continue;
            }

            Edicao edicaoOriginal = obterOuCriarEdicaoOriginal(historiaDto.publicacaoOriginal(), importacao, contadores);
            criarLinkCompraAmazonSeNecessario(edicaoOriginal, historiaDto.publicacaoOriginal(), contadores);
            criarConteudoOriginalSeNecessario(edicaoOriginal, historia, historiaDto, contadores);
            criarPublicacaoSeNecessario(edicaoOriginal, edicaoBrasileira, historia, historiaDto, importacao, contadores);
        }
    }

    private Historia obterOuCriarHistoria(HistoriaImportacaoDTO dto, ContadoresImportacao contadores) {
        String idExterno = idHistoria(dto);
        Optional<Historia> existente = historiaRepository.buscarPorOrigemExterna(FONTE_GUIA_DOS_QUADRINHOS, idExterno);
        if (existente.isPresent()) {
            atualizarHistoria(existente.get(), dto);
            contadores.itensReaproveitados++;
            return existente.get();
        }

        Historia historia = new Historia();
        historia.setTipo(TipoConteudoEdicao.HISTORIA);
        historia.setFonteExterna(FONTE_GUIA_DOS_QUADRINHOS);
        historia.setIdExterno(idExterno);
        atualizarHistoria(historia, dto);
        historiaRepository.persist(historia);
        contadores.historiasCriadas++;
        return historia;
    }

    private void atualizarHistoria(Historia historia, HistoriaImportacaoDTO dto) {
        copiarSeInformado(tituloPreferencial(dto), historia::setTitulo, 255);
        copiarSeInformado(dto.tituloPortugues(), historia::setTituloPortugues, 255);
        copiarSeInformado(dto.tituloOriginal(), historia::setTituloOriginal, 255);
        copiarSeInformado(dto.resumo(), historia::setDescricaoPortugues, 4000);
        copiarSeInformado(dto.resumo(), historia::setDescricao, 4000);
        if (dto.quantidadePaginas() != null) {
            historia.setQuantidadePaginas(dto.quantidadePaginas());
        }
    }

    private Edicao obterOuCriarEdicaoOriginal(
            PublicacaoOriginalImportacaoDTO dto,
            ImportacaoCatalogoDTO importacao,
            ContadoresImportacao contadores) {
        Editora editora = obterOuCriarEditora(editoraOriginal(dto), contadores);
        Serie serie = obterOuCriarSerieOriginal(dto, editora, importacao, contadores);
        String idExterno = idEdicaoOriginal(dto);

        Optional<Edicao> existente = edicaoRepository.buscarPorOrigemExterna(FONTE_GUIA_DOS_QUADRINHOS, idExterno);
        if (existente.isEmpty()) {
            existente = edicaoRepository.buscarPorNumeroESerie(dto.numeroOriginal(), serie.getId());
        }

        if (existente.isPresent()) {
            atualizarDadosComicVineOriginal(existente.get(), dto);
            enriquecerEdicaoOriginalComicVine(existente.get(), dto, editora.getNome());
            contadores.itensReaproveitados++;
            return existente.get();
        }

        Edicao edicao = new Edicao();
        edicao.setSerie(serie);
        edicao.setNumero(limitar(dto.numeroOriginal(), 255));
        edicao.setTitulo(limitar(dto.texto(), 255));
        edicao.setDataPublicacao(dataOriginal(dto.anoOriginal()));
        edicao.setFonteExterna(FONTE_GUIA_DOS_QUADRINHOS);
        edicao.setIdExterno(idExterno);
        edicao.setUrlOrigem(urlOrigem(importacao));
        atualizarDadosComicVineOriginal(edicao, dto);
        enriquecerEdicaoOriginalComicVine(edicao, dto, editora.getNome());
        edicaoRepository.persist(edicao);
        contadores.edicoesCriadas++;
        return edicao;
    }

    private Serie obterOuCriarSerieOriginal(
            PublicacaoOriginalImportacaoDTO dto,
            Editora editora,
            ImportacaoCatalogoDTO importacao,
            ContadoresImportacao contadores) {
        Optional<Serie> existente = serieRepository
                .find("lower(titulo) = ?1 and editora.id = ?2 and volume is null",
                        normalizarBusca(dto.serieOriginal()), editora.getId())
                .firstResultOptional();

        if (existente.isPresent()) {
            contadores.itensReaproveitados++;
            return existente.get();
        }

        Serie serie = new Serie();
        serie.setTitulo(limitar(dto.serieOriginal(), 255));
        serie.setAnoInicio(anoNoTitulo(dto.serieOriginal()));
        serie.setEditora(editora);
        serie.setFonteExterna(FONTE_GUIA_DOS_QUADRINHOS);
        serie.setIdExterno(idSerieOriginal(dto.serieOriginal(), editora.getNome()));
        serie.setUrlOrigem(urlOrigem(importacao));
        serieRepository.persist(serie);
        contadores.seriesCriadas++;
        return serie;
    }

    private Editora obterOuCriarEditora(String nome, ContadoresImportacao contadores) {
        String nomeLimpo = textoOuPadrao(nome, "Editora não informada");
        Optional<Editora> existente = editoraRepository.buscarPorNome(nomeLimpo);
        if (existente.isPresent()) {
            contadores.itensReaproveitados++;
            return existente.get();
        }

        Editora editora = new Editora();
        editora.setNome(limitar(nomeLimpo, 255));
        editora.setFonteExterna(FONTE_GUIA_DOS_QUADRINHOS);
        editora.setIdExterno(chave(nomeLimpo));
        editoraRepository.persist(editora);
        contadores.editorasCriadas++;
        return editora;
    }

    private void atualizarEdicao(Edicao edicao, EdicaoImportacaoDTO dto, ImportacaoCatalogoDTO importacao) {
        edicao.setTitulo(limitar(dto.tituloChamada(), 255));
        edicao.setDescricao(limitar(dto.descricao(), 2000));
        edicao.setDescricaoPortugues(limitar(dto.descricao(), 4000));
        edicao.setDataPublicacao(dto.dataPublicacao());
        if (deveAtualizarCapa(edicao.getUrlCapa(), dto.urlCapa())) {
            edicao.setUrlCapa(limitar(dto.urlCapa(), 1000));
        }
        edicao.setQuantidadePaginas(dto.numeroPaginas());
        edicao.setPrecoCapa(dto.precoCapa());
        edicao.setUrlOrigem(urlOrigem(importacao));
    }

    private void atualizarDadosComicVineOriginal(Edicao edicao, PublicacaoOriginalImportacaoDTO dto) {
        copiarSeInformado(dto.nomeVolume(), edicao::setNomeVolume, 255);
        copiarSeInformado(dto.titulo(), edicao::setTitulo, 255);
        copiarSeInformado(dto.descricaoOriginal(), edicao::setDescricaoOriginal, 4000);
        copiarSeInformado(dto.descricaoPortugues(), edicao::setDescricaoPortugues, 4000);
        copiarSeInformado(dto.urlOrigem(), edicao::setUrlOrigem, 1000);

        if (dto.urlCapa() != null && !dto.urlCapa().isBlank()
                && (edicao.getUrlCapa() == null || edicao.getUrlCapa().isBlank())) {
            edicao.setUrlCapa(limitar(dto.urlCapa(), 1000));
        }

        if (dto.dataCapa() != null) {
            edicao.setDataCobertura(dto.dataCapa());
            if (edicao.getDataPublicacao() == null) {
                edicao.setDataPublicacao(dto.dataCapa());
            }
        }

        if (dto.dataVenda() != null) {
            edicao.setDataDisponibilidadeLoja(dto.dataVenda());
            if (edicao.getDataPublicacao() == null) {
                edicao.setDataPublicacao(dto.dataVenda());
            }
        }

    }

    private boolean enriquecerEdicaoOriginalComicVine(
            Edicao edicao,
            PublicacaoOriginalImportacaoDTO dto,
            String editoraOriginal) {
        if (temDadosComicVineCompletos(edicao)) {
            return false;
        }

        try {
            Optional<EdicaoComicVineRespostaDTO> encontrada = integracaoExternaService.resolverEdicaoComicVineOriginal(
                    dto.serieOriginal(),
                    dto.numeroOriginal(),
                    dto.anoOriginal(),
                    editoraOriginal);
            if (encontrada.isEmpty()) {
                return false;
            }

            aplicarDadosComicVineOriginal(edicao, encontrada.get());
            return true;
        } catch (Throwable e) {
            return false;
        }
    }

    private boolean enriquecerEdicaoOriginalComicVine(Edicao edicao) {
        if (temDadosComicVineCompletos(edicao)) {
            return false;
        }

        try {
            Optional<EdicaoComicVineRespostaDTO> encontrada = integracaoExternaService.resolverEdicaoComicVineOriginal(
                    edicao.getSerie().getTitulo(),
                    edicao.getNumero(),
                    edicao.getDataPublicacao() == null ? edicao.getSerie().getAnoInicio() : edicao.getDataPublicacao().getYear(),
                    edicao.getSerie().getEditora().getNome());
            if (encontrada.isEmpty()) {
                return false;
            }

            aplicarDadosComicVineOriginal(edicao, encontrada.get());
            return true;
        } catch (Throwable e) {
            return false;
        }
    }

    private void aplicarDadosComicVineOriginal(Edicao edicao, EdicaoComicVineRespostaDTO comicVine) {
        edicao.setIdComicVine(limitar(comicVine.idExterno(), 100));
        edicao.setUrlComicVine(limitar(comicVine.urlOrigem(), 1000));
        edicao.setUrlCapa(limitar(comicVine.urlImagem(), 1000));
        copiarSeInformado(comicVine.nomeVolume(), edicao::setNomeVolume, 255);
        copiarSeInformado(comicVine.titulo(), edicao::setTitulo, 255);
        copiarSeInformado(comicVine.descricaoOriginal(), edicao::setDescricaoOriginal, 4000);
        copiarSeInformado(comicVine.descricaoPortugues(), edicao::setDescricaoPortugues, 4000);

        LocalDate dataCapa = dataComicVine(comicVine.dataCapa());
        if (dataCapa != null) {
            edicao.setDataCobertura(dataCapa);
        }

        LocalDate dataVenda = dataComicVine(comicVine.dataVenda());
        if (dataVenda != null) {
            edicao.setDataDisponibilidadeLoja(dataVenda);
        }
    }

    private void criarLinkCompraAmazonSeNecessario(
            Edicao edicaoOriginal,
            PublicacaoOriginalImportacaoDTO dto,
            ContadoresImportacao contadores) {
        if (dto.urlCompraAmazon() == null || dto.urlCompraAmazon().isBlank()) {
            return;
        }

        String url = limitar(dto.urlCompraAmazon(), 1000);
        if (linkEdicaoRepository.existePorEdicaoEUrl(edicaoOriginal.getId(), url)) {
            contadores.itensReaproveitados++;
            return;
        }

        LinkEdicao link = new LinkEdicao();
        link.setEdicao(edicaoOriginal);
        link.setTipo(TipoLinkEdicao.AMAZON);
        link.setTitulo("Comprar na Amazon");
        link.setUrl(url);
        link.setObservacoes("Link de compra informado na importacao.");
        linkEdicaoRepository.persist(link);
    }

    private boolean temDadosComicVineCompletos(Edicao edicao) {
        return !estaVazio(edicao.getIdComicVine())
                && !estaVazio(edicao.getUrlComicVine())
                && !estaVazio(edicao.getUrlCapa());
    }

    private LocalDate dataComicVine(String data) {
        if (data == null || data.isBlank()) {
            return null;
        }

        try {
            return LocalDate.parse(data);
        } catch (RuntimeException e) {
            return null;
        }
    }

    private boolean deveAtualizarCapa(String capaAtual, String novaCapa) {
        if (novaCapa == null || novaCapa.isBlank()) {
            return false;
        }

        if (capaAtual == null || capaAtual.isBlank()) {
            return true;
        }

        boolean capaAtualGuia = capaAtual.contains("guiadosquadrinhos.com/edicao/ShowImage.aspx");
        boolean novaCapaGuia = novaCapa.contains("guiadosquadrinhos.com/edicao/ShowImage.aspx");
        return capaAtualGuia || !novaCapaGuia;
    }

    private void criarConteudoSeNecessario(
            Edicao edicao,
            Historia historia,
            HistoriaImportacaoDTO dto,
            int ordem,
            ContadoresImportacao contadores) {
        Optional<ConteudoEdicao> existente = conteudoEdicaoRepository.buscarPorEdicaoEHistoria(edicao.getId(), historia.getId());
        if (existente.isPresent()) {
            atualizarConteudoImportado(existente.get(), dto, ordem, true);
            contadores.itensReaproveitados++;
            return;
        }

        if (conteudoEdicaoRepository.existePorEdicaoEOrdem(edicao.getId(), ordem)) {
            contadores.itensReaproveitados++;
            return;
        }

        ConteudoEdicao conteudo = new ConteudoEdicao();
        conteudo.setEdicao(edicao);
        conteudo.setHistoria(historia);
        conteudo.setTipo(TipoConteudoEdicao.HISTORIA);
        atualizarConteudoImportado(conteudo, dto, ordem, true);
        conteudoEdicaoRepository.persist(conteudo);
        contadores.conteudosCriados++;
    }

    private void criarConteudoOriginalSeNecessario(
            Edicao edicaoOriginal,
            Historia historia,
            HistoriaImportacaoDTO dto,
            ContadoresImportacao contadores) {
        Optional<ConteudoEdicao> existente = conteudoEdicaoRepository.buscarPorEdicaoEHistoria(edicaoOriginal.getId(), historia.getId());
        if (existente.isPresent()) {
            atualizarConteudoImportado(existente.get(), dto, existente.get().getOrdem(), false);
            contadores.itensReaproveitados++;
            return;
        }

        ConteudoEdicao conteudo = new ConteudoEdicao();
        conteudo.setEdicao(edicaoOriginal);
        conteudo.setHistoria(historia);
        conteudo.setTipo(TipoConteudoEdicao.HISTORIA);
        atualizarConteudoImportado(conteudo, dto, (int) conteudoEdicaoRepository.contarPorEdicao(edicaoOriginal.getId()) + 1, false);
        conteudoEdicaoRepository.persist(conteudo);
        contadores.conteudosCriados++;
    }

    private void atualizarConteudoImportado(ConteudoEdicao conteudo, HistoriaImportacaoDTO dto, int ordem, boolean publicacaoBrasileira) {
        conteudo.setOrdem(ordem);
        copiarSeInformado(publicacaoBrasileira ? dto.tituloPortugues() : tituloPreferencial(dto), conteudo::setTituloUsado, 255);
        copiarSeInformado(dto.resumo(), conteudo::setObservacoes, 1000);
        if (dto.quantidadePaginas() != null) {
            conteudo.setQuantidadePaginas(dto.quantidadePaginas());
        }
    }

    private void criarPublicacaoSeNecessario(
            Edicao edicaoOriginal,
            Edicao edicaoBrasileira,
            Historia historia,
            HistoriaImportacaoDTO dto,
            ImportacaoCatalogoDTO importacao,
            ContadoresImportacao contadores) {
        if (mesmaEdicaoCatalografica(edicaoOriginal, edicaoBrasileira)) {
            contadores.itensReaproveitados++;
            return;
        }

        Optional<PublicacaoHistoria> existente = publicacaoHistoriaRepository.buscarPorHistoriaEEdicaoPublicada(historia.getId(), edicaoBrasileira.getId());
        if (existente.isPresent()) {
            atualizarPublicacaoImportada(existente.get(), dto, importacao);
            contadores.itensReaproveitados++;
            return;
        }

        PublicacaoHistoria publicacao = new PublicacaoHistoria();
        publicacao.setHistoria(historia);
        publicacao.setEdicaoOriginal(edicaoOriginal);
        publicacao.setEdicaoPublicada(edicaoBrasileira);
        publicacao.setStatus(StatusPublicacaoHistoria.COMPLETA);
        publicacao.setTipoPublicacaoHistoria(TipoPublicacaoHistoria.PUBLICACAO_BRASILEIRA);
        publicacao.setStatusValidacao(StatusValidacao.APROVADA);
        publicacao.setFonteExterna(FONTE_GUIA_DOS_QUADRINHOS);
        atualizarPublicacaoImportada(publicacao, dto, importacao);
        publicacaoHistoriaRepository.persist(publicacao);
        contadores.publicacoesCriadas++;
    }

    private void atualizarPublicacaoImportada(
            PublicacaoHistoria publicacao,
            HistoriaImportacaoDTO dto,
            ImportacaoCatalogoDTO importacao) {
        publicacao.setFonteInformacao(FONTE_GUIA_DOS_QUADRINHOS);
        publicacao.setUrlFonteInformacao(urlOrigem(importacao));
        publicacao.setFonteExterna(FONTE_GUIA_DOS_QUADRINHOS);
        publicacao.setUrlOrigem(urlOrigem(importacao));
        copiarSeInformado(dto.tituloPortugues(), publicacao::setTituloUsado, 255);
        copiarSeInformado(dto.resumo(), publicacao::setObservacoes, 1000);
        if (dto.quantidadePaginas() != null) {
            publicacao.setPaginasPublicadas(dto.quantidadePaginas());
        }
    }

    private boolean mesmaEdicaoCatalografica(Edicao primeira, Edicao segunda) {
        if (primeira.getId() != null && primeira.getId().equals(segunda.getId())) {
            return true;
        }

        return normalizarBusca(primeira.getNumero()).equals(normalizarBusca(segunda.getNumero()))
                && primeira.getSerie() != null
                && segunda.getSerie() != null
                && normalizarBusca(primeira.getSerie().getTitulo()).equals(normalizarBusca(segunda.getSerie().getTitulo()));
    }

    private String editoraOriginal(PublicacaoOriginalImportacaoDTO dto) {
        if (dto.texto() == null || !dto.texto().contains(" - ")) {
            return "Editora original não informada";
        }

        return dto.texto().substring(dto.texto().lastIndexOf(" - ") + 3).trim();
    }

    private LocalDate dataOriginal(Integer ano) {
        return ano == null ? null : LocalDate.of(ano, 1, 1);
    }

    private Integer anoNoTitulo(String texto) {
        if (texto == null) {
            return null;
        }

        java.util.regex.Matcher matcher = java.util.regex.Pattern.compile("\\((\\d{4})\\)").matcher(texto);
        return matcher.find() ? Integer.valueOf(matcher.group(1)) : null;
    }

    private String urlOrigem(ImportacaoCatalogoDTO dto) {
        if (dto.origem() == null) {
            return null;
        }

        if (dto.origem().url() != null && !dto.origem().url().isBlank()) {
            return dto.origem().url();
        }

        if (dto.origem().urlsProcessadas() != null && !dto.origem().urlsProcessadas().isEmpty()) {
            return dto.origem().urlsProcessadas().get(0);
        }

        return null;
    }

    private String tituloPreferencial(HistoriaImportacaoDTO dto) {
        return textoOuPadrao(dto.tituloPortugues(), dto.tituloOriginal());
    }

    private String idSerieBrasileira(SerieBrasileiraImportacaoDTO dto) {
        return chave(dto.editora(), dto.titulo(), Objects.toString(dto.volume(), ""));
    }

    private String idSerieOriginal(String titulo, String editora) {
        return chave(editora, titulo);
    }

    private String idEdicaoBrasileira(Serie serie, EdicaoImportacaoDTO dto) {
        return chave(serie.getEditora().getNome(), serie.getTitulo(), Objects.toString(serie.getVolume(), ""), dto.numero());
    }

    private String idEdicaoOriginal(PublicacaoOriginalImportacaoDTO dto) {
        return chave(dto.serieOriginal(), dto.numeroOriginal(), Objects.toString(dto.anoOriginal(), ""));
    }

    private String idHistoria(HistoriaImportacaoDTO dto) {
        if (dto.publicacaoOriginal() != null) {
            return chave(
                    dto.publicacaoOriginal().serieOriginal(),
                    dto.publicacaoOriginal().numeroOriginal(),
                    Objects.toString(dto.publicacaoOriginal().anoOriginal(), ""),
                    tituloPreferencial(dto));
        }

        return chave(tituloPreferencial(dto), Objects.toString(dto.ordem(), ""));
    }

    private String chave(String... partes) {
        List<String> limpas = new ArrayList<>();
        for (String parte : partes) {
            if (parte != null && !parte.isBlank()) {
                limpas.add(parte.trim().toLowerCase(Locale.ROOT));
            }
        }

        String chave = String.join("|", limpas);
        if (chave.length() <= TAMANHO_MAXIMO_ID_EXTERNO) {
            return chave;
        }

        return "hash:" + gerarHash(chave);
    }

    private String gerarHash(String valor) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(valor.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("Não foi possível gerar hash para importação.", e);
        }
    }

    private String normalizarBusca(String valor) {
        return valor == null ? "" : valor.trim().toLowerCase(Locale.ROOT);
    }

    private String textoOuPadrao(String texto, String padrao) {
        return texto == null || texto.isBlank() ? padrao : NormalizadorTexto.corrigirMojibake(texto.trim());
    }

    private void adicionarAvisoBackfill(List<String> avisos, String mensagem) {
        if (avisos.size() < LIMITE_AVISOS_BACKFILL) {
            avisos.add(mensagem);
        }
    }

    private boolean estaVazio(String texto) {
        return texto == null || texto.isBlank();
    }

    private String limitar(String texto, int tamanho) {
        if (texto == null) {
            return null;
        }

        String limpo = NormalizadorTexto.corrigirMojibake(texto.trim());
        return limpo.length() <= tamanho ? limpo : limpo.substring(0, tamanho);
    }

    private void copiarSeInformado(String valor, java.util.function.Consumer<String> destino, int tamanho) {
        if (valor != null && !valor.isBlank()) {
            destino.accept(limitar(valor, tamanho));
        }
    }

    private void publicarNovidadeNoFeed(
            Serie serie,
            ImportacaoCatalogoDTO importacao,
            ContadoresImportacao contadores,
            List<String> avisos) {
        if (contadores.seriesCriadas == 0 && contadores.edicoesCriadas == 0 && contadores.edicoesAtualizadas == 0) {
            return;
        }

        try {
            Usuario usuario = usuarioAutenticadoService.obterUsuario();
            PostagemFeed postagem = new PostagemFeed();
            postagem.setUsuario(usuario);
            postagem.setSistema(true);
            postagem.setConteudo(textoNovidadeFeed(usuario, serie, importacao.serieBrasileira(), contadores));
            postagem.setUrlImagem(primeiraCapaImportacao(importacao));
            postagem.setSerieCatalogo(serie);
            postagemFeedRepository.persist(postagem);
        } catch (RuntimeException e) {
            avisos.add("Nao foi possivel publicar a novidade no feed: "
                    + e.getClass().getSimpleName() + " - " + textoOuPadrao(e.getMessage(), "sem detalhes"));
        }
    }

    private String textoNovidadeFeed(
            Usuario usuario,
            Serie serie,
            SerieBrasileiraImportacaoDTO serieDto,
            ContadoresImportacao contadores) {
        String nome = usuario.getNome() == null || usuario.getNome().isBlank()
                ? "Um colaborador"
                : limitar(usuario.getNome(), 80);
        String acao = contadores.seriesCriadas > 0 || contadores.edicoesCriadas > 0 ? "adicionou" : "editou";
        String titulo = tituloParaFeed(serie.getTitulo());
        String fase = serieDto.fase() == null || serieDto.fase().isBlank()
                ? ""
                : " " + limitar(serieDto.fase(), 80);
        return limitar(nome + " " + acao + " " + titulo + fase + " no nosso catalogo.", 2000);
    }

    private String tituloParaFeed(String titulo) {
        if (titulo == null || titulo.isBlank()) {
            return "uma nova serie";
        }

        String limpo = limitar(titulo, 255);
        if (limpo.endsWith(", A")) {
            return "A " + limpo.substring(0, limpo.length() - 3);
        }
        if (limpo.endsWith(", O")) {
            return "O " + limpo.substring(0, limpo.length() - 3);
        }
        return limpo;
    }

    private String primeiraCapaImportacao(ImportacaoCatalogoDTO importacao) {
        if (importacao.edicoes() == null) {
            return null;
        }

        return importacao.edicoes().stream()
                .map(EdicaoImportacaoDTO::urlCapa)
                .filter(url -> url != null && !url.isBlank())
                .map(url -> limitar(url, 1000))
                .findFirst()
                .orElse(null);
    }

    private static class ContadoresImportacao {
        int editorasCriadas;
        int seriesCriadas;
        int edicoesCriadas;
        int edicoesAtualizadas;
        int historiasCriadas;
        int conteudosCriados;
        int publicacoesCriadas;
        int itensReaproveitados;
    }
}
