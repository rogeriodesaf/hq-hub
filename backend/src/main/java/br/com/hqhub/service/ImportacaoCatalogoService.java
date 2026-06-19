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
import br.com.hqhub.dto.HistoriaImportacaoDTO;
import br.com.hqhub.dto.ImportacaoCatalogoDTO;
import br.com.hqhub.dto.PublicacaoOriginalImportacaoDTO;
import br.com.hqhub.dto.ResultadoImportacaoCatalogoDTO;
import br.com.hqhub.dto.SerieBrasileiraImportacaoDTO;
import br.com.hqhub.entity.ConteudoEdicao;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.Editora;
import br.com.hqhub.entity.Historia;
import br.com.hqhub.entity.PublicacaoHistoria;
import br.com.hqhub.entity.Serie;
import br.com.hqhub.entity.StatusPublicacaoHistoria;
import br.com.hqhub.entity.StatusValidacao;
import br.com.hqhub.entity.TipoConteudoEdicao;
import br.com.hqhub.entity.TipoPublicacaoHistoria;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.repository.ConteudoEdicaoRepository;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.EditoraRepository;
import br.com.hqhub.repository.HistoriaRepository;
import br.com.hqhub.repository.PublicacaoHistoriaRepository;
import br.com.hqhub.repository.SerieRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class ImportacaoCatalogoService {

    private static final String FONTE_GUIA_DOS_QUADRINHOS = "GUIA_DOS_QUADRINHOS";
    private static final int TAMANHO_MAXIMO_ID_EXTERNO = 100;

    private final EditoraRepository editoraRepository;
    private final SerieRepository serieRepository;
    private final EdicaoRepository edicaoRepository;
    private final HistoriaRepository historiaRepository;
    private final ConteudoEdicaoRepository conteudoEdicaoRepository;
    private final PublicacaoHistoriaRepository publicacaoHistoriaRepository;

    public ImportacaoCatalogoService(
            EditoraRepository editoraRepository,
            SerieRepository serieRepository,
            EdicaoRepository edicaoRepository,
            HistoriaRepository historiaRepository,
            ConteudoEdicaoRepository conteudoEdicaoRepository,
            PublicacaoHistoriaRepository publicacaoHistoriaRepository) {
        this.editoraRepository = editoraRepository;
        this.serieRepository = serieRepository;
        this.edicaoRepository = edicaoRepository;
        this.historiaRepository = historiaRepository;
        this.conteudoEdicaoRepository = conteudoEdicaoRepository;
        this.publicacaoHistoriaRepository = publicacaoHistoriaRepository;
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
        Optional<Serie> existente = serieRepository
                .find("lower(titulo) = ?1 and editora.id = ?2 and coalesce(volume, 0) = ?3",
                        normalizarBusca(dto.titulo()), editora.getId(), dto.volume() == null ? 0 : dto.volume())
                .firstResultOptional();

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
            existente = edicaoRepository
                    .find("lower(numero) = ?1 and serie.id = ?2", normalizarBusca(dto.numero()), serie.getId())
                    .firstResultOptional();
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
            criarConteudoOriginalSeNecessario(edicaoOriginal, historia, historiaDto, contadores);
            criarPublicacaoSeNecessario(edicaoOriginal, edicaoBrasileira, historia, historiaDto, importacao, contadores);
        }
    }

    private Historia obterOuCriarHistoria(HistoriaImportacaoDTO dto, ContadoresImportacao contadores) {
        String idExterno = idHistoria(dto);
        Optional<Historia> existente = historiaRepository.buscarPorOrigemExterna(FONTE_GUIA_DOS_QUADRINHOS, idExterno);
        if (existente.isPresent()) {
            contadores.itensReaproveitados++;
            return existente.get();
        }

        Historia historia = new Historia();
        historia.setTitulo(limitar(tituloPreferencial(dto), 255));
        historia.setTituloPortugues(limitar(dto.tituloPortugues(), 255));
        historia.setTituloOriginal(limitar(dto.tituloOriginal(), 255));
        historia.setDescricaoPortugues(limitar(dto.resumo(), 4000));
        historia.setQuantidadePaginas(dto.quantidadePaginas());
        historia.setTipo(TipoConteudoEdicao.HISTORIA);
        historia.setFonteExterna(FONTE_GUIA_DOS_QUADRINHOS);
        historia.setIdExterno(idExterno);
        historiaRepository.persist(historia);
        contadores.historiasCriadas++;
        return historia;
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
            existente = edicaoRepository
                    .find("lower(numero) = ?1 and serie.id = ?2", normalizarBusca(dto.numeroOriginal()), serie.getId())
                    .firstResultOptional();
        }

        if (existente.isPresent()) {
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
        if (conteudoEdicaoRepository.buscarPorEdicaoEHistoria(edicao.getId(), historia.getId()).isPresent()
                || conteudoEdicaoRepository.existePorEdicaoEOrdem(edicao.getId(), ordem)) {
            contadores.itensReaproveitados++;
            return;
        }

        ConteudoEdicao conteudo = new ConteudoEdicao();
        conteudo.setEdicao(edicao);
        conteudo.setHistoria(historia);
        conteudo.setOrdem(ordem);
        conteudo.setTituloUsado(limitar(dto.tituloPortugues(), 255));
        conteudo.setQuantidadePaginas(dto.quantidadePaginas());
        conteudo.setTipo(TipoConteudoEdicao.HISTORIA);
        conteudo.setObservacoes(limitar(dto.resumo(), 1000));
        conteudoEdicaoRepository.persist(conteudo);
        contadores.conteudosCriados++;
    }

    private void criarConteudoOriginalSeNecessario(
            Edicao edicaoOriginal,
            Historia historia,
            HistoriaImportacaoDTO dto,
            ContadoresImportacao contadores) {
        if (conteudoEdicaoRepository.buscarPorEdicaoEHistoria(edicaoOriginal.getId(), historia.getId()).isPresent()) {
            contadores.itensReaproveitados++;
            return;
        }

        ConteudoEdicao conteudo = new ConteudoEdicao();
        conteudo.setEdicao(edicaoOriginal);
        conteudo.setHistoria(historia);
        conteudo.setOrdem((int) conteudoEdicaoRepository.contarPorEdicao(edicaoOriginal.getId()) + 1);
        conteudo.setTituloUsado(limitar(tituloPreferencial(dto), 255));
        conteudo.setQuantidadePaginas(dto.quantidadePaginas());
        conteudo.setTipo(TipoConteudoEdicao.HISTORIA);
        conteudoEdicaoRepository.persist(conteudo);
        contadores.conteudosCriados++;
    }

    private void criarPublicacaoSeNecessario(
            Edicao edicaoOriginal,
            Edicao edicaoBrasileira,
            Historia historia,
            HistoriaImportacaoDTO dto,
            ImportacaoCatalogoDTO importacao,
            ContadoresImportacao contadores) {
        if (publicacaoHistoriaRepository.existePorHistoriaEEdicaoPublicada(historia.getId(), edicaoBrasileira.getId())) {
            contadores.itensReaproveitados++;
            return;
        }

        PublicacaoHistoria publicacao = new PublicacaoHistoria();
        publicacao.setHistoria(historia);
        publicacao.setEdicaoOriginal(edicaoOriginal);
        publicacao.setEdicaoPublicada(edicaoBrasileira);
        publicacao.setStatus(StatusPublicacaoHistoria.COMPLETA);
        publicacao.setTipoPublicacaoHistoria(TipoPublicacaoHistoria.PUBLICACAO_BRASILEIRA);
        publicacao.setFonteInformacao(FONTE_GUIA_DOS_QUADRINHOS);
        publicacao.setUrlFonteInformacao(urlOrigem(importacao));
        publicacao.setStatusValidacao(StatusValidacao.APROVADA);
        publicacao.setTituloUsado(limitar(dto.tituloPortugues(), 255));
        publicacao.setPaginasPublicadas(dto.quantidadePaginas());
        publicacao.setFonteExterna(FONTE_GUIA_DOS_QUADRINHOS);
        publicacao.setUrlOrigem(urlOrigem(importacao));
        publicacaoHistoriaRepository.persist(publicacao);
        contadores.publicacoesCriadas++;
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
        return texto == null || texto.isBlank() ? padrao : texto.trim();
    }

    private String limitar(String texto, int tamanho) {
        if (texto == null) {
            return null;
        }

        String limpo = texto.trim();
        return limpo.length() <= tamanho ? limpo : limpo.substring(0, tamanho);
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
