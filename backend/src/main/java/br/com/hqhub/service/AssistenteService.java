package br.com.hqhub.service;

import java.text.Normalizer;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.EnumSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import br.com.hqhub.dto.ColecaoResumoDTO;
import br.com.hqhub.dto.CompraPlanejadaRespostaDTO;
import br.com.hqhub.dto.CreditoEdicaoRespostaDTO;
import br.com.hqhub.dto.EdicaoRespostaDTO;
import br.com.hqhub.dto.RelacionamentoSerieRespostaDTO;
import br.com.hqhub.dto.RespostaAssistenteDTO;
import br.com.hqhub.dto.ResultadoBuscaConhecimentoDTO;
import br.com.hqhub.dto.SerieCompletudeDTO;
import br.com.hqhub.entity.Criador;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.PapelCriador;
import br.com.hqhub.entity.Serie;
import br.com.hqhub.entity.TipoSerie;
import br.com.hqhub.repository.CriadorRepository;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.SerieRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class AssistenteService {

    private static final String ORIGEM_BANCO_LOCAL = "BANCO_LOCAL";
    private static final String ORIGEM_NAO_ENCONTRADO = "NAO_ENCONTRADO";
    private static final String ORIGEM_CONHECIMENTO_EDITORIAL = "CONHECIMENTO_EDITORIAL";
    private static final String ORIGEM_CONHECIMENTO_ESSENCIAL = "CONHECIMENTO_ESSENCIAL";
    private static final String PREFERENCIA_TEX = "\n\nMas, entre nos, eu prefiro o Tex.";
    private static final Pattern PADRAO_ID = Pattern.compile("\\b(?:id|serieId|sérieId|serie|série)\\s*[:=]?\\s*(\\d+)\\b",
            Pattern.CASE_INSENSITIVE);
    private static final Pattern PADRAO_ANO = Pattern.compile("\\b(20\\d{2}|19\\d{2})\\b");
    private static final Pattern PADRAO_NUMERO_EDICAO = Pattern.compile(
            "(?i)(?:\\bedi[cç][aã]o\\s*(?:n[º°o.]\\s*)?|\\bn[º°o.]\\s*|#)\\s*([0-9]+(?:[.,/-][0-9a-z]+)?)");
    private static final Pattern PADRAO_VOLUME = Pattern.compile("(?i)\\b(?:v|volume)\\s*([0-9]+)\\b");
    private static final DateTimeFormatter FORMATO_DATA = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final Set<String> TERMOS_PERGUNTA_QUANTIDADE = Set.of(
            "quantas", "quantos", "quantidade", "total", "edicao", "edicoes", "numero", "numeros",
            "revista", "revistas", "hq", "hqs", "gibi", "gibis", "volume", "volumes",
            "titulo", "titulos", "serie", "series",
            "cadastrada", "cadastradas", "cadastrado", "cadastrados", "cadastro", "catalogo",
            "existe", "existem", "tem", "possui", "possuem", "ha", "quero", "saber", "diga",
            "me", "mostre", "no", "na", "nos", "nas", "do", "da", "dos", "das", "de", "em",
            "pelo", "pela", "por", "um", "uma", "o", "a", "os", "as", "hqhub", "hub");
    private static final Map<String, String> CONHECIMENTOS_ESSENCIAIS = criarConhecimentosEssenciais();

    private final ResumoColecaoService resumoColecaoService;
    private final FaltanteService faltanteService;
    private final CompraPlanejadaService compraPlanejadaService;
    private final CreditoEdicaoService creditoEdicaoService;
    private final RelacionamentoSerieService relacionamentoSerieService;
    private final ConhecimentoEditorialService conhecimentoEditorialService;
    private final SerieRepository serieRepository;
    private final EdicaoRepository edicaoRepository;
    private final CriadorRepository criadorRepository;

    public AssistenteService(
            ResumoColecaoService resumoColecaoService,
            FaltanteService faltanteService,
            CompraPlanejadaService compraPlanejadaService,
            CreditoEdicaoService creditoEdicaoService,
            RelacionamentoSerieService relacionamentoSerieService,
            ConhecimentoEditorialService conhecimentoEditorialService,
            SerieRepository serieRepository,
            EdicaoRepository edicaoRepository,
            CriadorRepository criadorRepository) {
        this.resumoColecaoService = resumoColecaoService;
        this.faltanteService = faltanteService;
        this.compraPlanejadaService = compraPlanejadaService;
        this.creditoEdicaoService = creditoEdicaoService;
        this.relacionamentoSerieService = relacionamentoSerieService;
        this.conhecimentoEditorialService = conhecimentoEditorialService;
        this.serieRepository = serieRepository;
        this.edicaoRepository = edicaoRepository;
        this.criadorRepository = criadorRepository;
    }

    @Transactional
    public RespostaAssistenteDTO responder(String pergunta) {
        String perguntaNormalizada = normalizar(pergunta);

        if (contemAlguma(perguntaNormalizada, "faltante", "faltam", "falta")) {
            return responderFaltantes(pergunta);
        }

        if (contemAlguma(perguntaNormalizada, "completude", "porcentagem", "percentual", "completa")) {
            return responderCompletude(pergunta);
        }

        if (ehPerguntaTotaisCatalogo(perguntaNormalizada)) {
            return responderTotaisCatalogo(pergunta);
        }

        if (ehPerguntaQuantidadeEdicoes(perguntaNormalizada)) {
            return responderQuantidadeEdicoesSerie(pergunta);
        }

        if (ehPerguntaDataCatalogo(perguntaNormalizada)) {
            return responderDataCatalogo(pergunta);
        }

        if (ehPerguntaDetalhesEdicao(perguntaNormalizada)) {
            return responderDetalhesEdicao(pergunta);
        }

        if (ehPerguntaCreditosCatalogo(perguntaNormalizada)) {
            return responderCreditosCatalogo(pergunta, perguntaNormalizada);
        }

        if (ehPerguntaListagemEdicoes(perguntaNormalizada)) {
            return responderListagemEdicoes(pergunta);
        }

        if (ehPerguntaFichaSerie(perguntaNormalizada)) {
            return responderFichaSerie(pergunta);
        }

        if (contemAlguma(perguntaNormalizada, "compra", "compras", "planejada", "planejadas", "mes")) {
            return responderCompras(pergunta, perguntaNormalizada);
        }

        if (contemAlguma(perguntaNormalizada, "criador", "autor", "roteirista", "desenhista", "artista")) {
            return responderCriador(pergunta);
        }

        if (contemAlguma(perguntaNormalizada, "continua", "continuacao", "v2", "volume", "reboot", "relancamento",
                "relacionamento")) {
            return responderRelacionamentos(pergunta);
        }

        if (ehPerguntaImportacaoGuiaBloqueada(perguntaNormalizada)) {
            return responderImportacaoGuiaBloqueada();
        }

        if (ehPerguntaResumoColecao(perguntaNormalizada)) {
            return responderResumo();
        }

        try {
            // Tentar consultar base editorial de conhecimento sobre quadrinhos
            List<ResultadoBuscaConhecimentoDTO> resultados = conhecimentoEditorialService.buscarRelevante(pergunta);
            if (!resultados.isEmpty()) {
                return responderComConhecimentoEditorial(resultados);
            }
        } catch (Exception excecao) {
            Optional<RespostaAssistenteDTO> respostaEssencial = responderComConhecimentoEssencial(perguntaNormalizada);
            if (respostaEssencial.isPresent()) {
                return respostaEssencial.get();
            }

            return new RespostaAssistenteDTO(
                    "Ainda nao consegui consultar a base editorial de quadrinhos. Tente novamente em instantes ou faca uma pergunta sobre sua colecao.",
                    ORIGEM_NAO_ENCONTRADO,
                    null);
        }

        Optional<RespostaAssistenteDTO> respostaEssencial = responderComConhecimentoEssencial(perguntaNormalizada);
        if (respostaEssencial.isPresent()) {
            return respostaEssencial.get();
        }

        if (ehPerguntaSobreSistema(perguntaNormalizada)) {
            return responderAjudaSistema();
        }

        return new RespostaAssistenteDTO(
                "Ainda não encontrei uma intenção clara. Posso consultar títulos e edições do catálogo, ano ou data de publicação, créditos de roteiro, arte, desenho, capa e outros papéis, quantidade de títulos, edições faltantes, completude, compras e continuidade entre séries.",
                ORIGEM_NAO_ENCONTRADO,
                null);
    }

    private RespostaAssistenteDTO responderResumo() {
        ColecaoResumoDTO resumo = resumoColecaoService.gerarResumo();

        String resposta = "Sua coleção tem %d item(ns), %d série(s), %d editora(s) e valor pago total de R$ %s."
                .formatted(
                        resumo.totalItens(),
                        resumo.totalSeries(),
                        resumo.totalEditoras(),
                        resumo.valorTotalPago());

        return new RespostaAssistenteDTO(resposta, ORIGEM_BANCO_LOCAL, resumo);
    }

    private RespostaAssistenteDTO responderFaltantes(String pergunta) {
        Optional<Serie> serieEncontrada = localizarSerie(pergunta);
        if (serieEncontrada.isEmpty()) {
            return respostaSerieNaoEncontrada();
        }

        Serie serie = serieEncontrada.get();
        List<EdicaoRespostaDTO> faltantes = faltanteService.listarFaltantesPorSerie(serie.getId());
        String resposta = faltantes.isEmpty()
                ? "Você não tem edições faltantes cadastradas para %s.".formatted(serie.getTitulo())
                : "Encontrei %d edição(ões) faltante(s) para %s.".formatted(faltantes.size(), serie.getTitulo());

        return new RespostaAssistenteDTO(resposta, ORIGEM_BANCO_LOCAL, faltantes);
    }

    private RespostaAssistenteDTO responderCompletude(String pergunta) {
        Optional<Serie> serieEncontrada = localizarSerie(pergunta);
        if (serieEncontrada.isEmpty()) {
            return respostaSerieNaoEncontrada();
        }

        SerieCompletudeDTO completude = resumoColecaoService.calcularCompletudePorSerie(serieEncontrada.get().getId());
        String resposta = "%s está com %s%% de completude: %d de %d edição(ões), faltando %d."
                .formatted(
                        completude.serie().titulo(),
                        completude.percentualCompleto(),
                        completude.totalPossuidas(),
                        completude.totalEdicoes(),
                        completude.totalFaltantes());

        return new RespostaAssistenteDTO(resposta, ORIGEM_BANCO_LOCAL, completude);
    }

    private RespostaAssistenteDTO responderCompras(String pergunta, String perguntaNormalizada) {
        Integer mes = extrairMes(perguntaNormalizada);
        Integer ano = extrairAno(pergunta);
        List<CompraPlanejadaRespostaDTO> compras = compraPlanejadaService.listar(mes, ano);

        String periodo = mes != null && ano != null
                ? " para %02d/%d".formatted(mes, ano)
                : "";
        String resposta = compras.isEmpty()
                ? "Você não tem compras planejadas%s.".formatted(periodo)
                : "Encontrei %d compra(s) planejada(s)%s.".formatted(compras.size(), periodo);

        return new RespostaAssistenteDTO(resposta, ORIGEM_BANCO_LOCAL, compras);
    }

    private RespostaAssistenteDTO responderCriador(String pergunta) {
        Optional<Criador> criadorEncontrado = localizarCriador(pergunta);
        if (criadorEncontrado.isEmpty()) {
            return new RespostaAssistenteDTO(
                    "Não encontrei esse criador no catálogo local. Cadastre o criador e os créditos das edições para eu conseguir listar as publicações em ordem cronológica.",
                    ORIGEM_NAO_ENCONTRADO,
                    null);
        }

        Criador criador = criadorEncontrado.get();
        List<CreditoEdicaoRespostaDTO> creditos = creditoEdicaoService.listarEdicoesPorCriador(criador.getId(), null);
        String resposta = creditos.isEmpty()
                ? "Encontrei %s, mas ainda não há créditos cadastrados para esse criador.".formatted(criador.getNome())
                : "Encontrei %d crédito(s) para %s, ordenados pela data de publicação das edições."
                        .formatted(creditos.size(), criador.getNome());

        return new RespostaAssistenteDTO(resposta, ORIGEM_BANCO_LOCAL, creditos);
    }

    private RespostaAssistenteDTO responderRelacionamentos(String pergunta) {
        Optional<Serie> serieEncontrada = localizarSerie(pergunta);
        if (serieEncontrada.isEmpty()) {
            return respostaSerieNaoEncontrada();
        }

        Serie serie = serieEncontrada.get();
        List<RelacionamentoSerieRespostaDTO> relacionamentos = relacionamentoSerieService.listarPorSerie(serie.getId());
        String resposta = relacionamentos.isEmpty()
                ? "Não há relacionamentos cadastrados para %s.".formatted(serie.getTitulo())
                : "Encontrei %d relacionamento(s) de continuidade ou ligação para %s."
                        .formatted(relacionamentos.size(), serie.getTitulo());

        return new RespostaAssistenteDTO(resposta, ORIGEM_BANCO_LOCAL, relacionamentos);
    }

    private RespostaAssistenteDTO responderTotaisCatalogo(String pergunta) {
        String assunto = extrairAssuntoQuantidade(pergunta);
        String filtro = assunto.isBlank() ? null : assunto;
        long totalSeries = serieRepository.contarComBusca(filtro, null, TipoSerie.BRASILEIRA);
        long totalEdicoes = edicaoRepository.contarComBusca(null, filtro, TipoSerie.BRASILEIRA);

        Map<String, Object> dados = new LinkedHashMap<>();
        dados.put("consulta", filtro);
        dados.put("totalTitulos", totalSeries);
        dados.put("totalEdicoes", totalEdicoes);
        dados.put("tipoCatalogo", TipoSerie.BRASILEIRA.name());

        String resposta = filtro == null
                ? "O catálogo do HQ-HUB tem %d título(s) nacional(is) e %d edição(ões) cadastrada(s)."
                        .formatted(totalSeries, totalEdicoes)
                : "Encontrei %d título(s) e %d edição(ões) relacionados a \"%s\" no catálogo do HQ-HUB."
                        .formatted(totalSeries, totalEdicoes, assunto);
        return new RespostaAssistenteDTO(resposta, ORIGEM_BANCO_LOCAL, dados);
    }

    private RespostaAssistenteDTO responderDataCatalogo(String pergunta) {
        Optional<Serie> serieEncontrada = localizarSerie(pergunta);
        if (serieEncontrada.isEmpty()) {
            return respostaSerieNaoEncontrada();
        }

        Serie serie = serieEncontrada.get();
        String numeroEdicao = extrairNumeroEdicao(pergunta);
        if (numeroEdicao != null) {
            Optional<Edicao> edicaoEncontrada = edicaoRepository.buscarPorNumeroESerie(numeroEdicao, serie.getId());
            if (edicaoEncontrada.isEmpty()) {
                return respostaEdicaoNaoEncontrada(serie, numeroEdicao);
            }

            Edicao edicao = edicaoEncontrada.get();
            LocalDate data = edicao.getDataPublicacao() != null
                    ? edicao.getDataPublicacao()
                    : edicao.getDataCobertura();
            String campoUsado = edicao.getDataPublicacao() != null ? "dataPublicacao" : "dataCobertura";
            if (data == null) {
                return new RespostaAssistenteDTO(
                        "A edição nº %s de %s está cadastrada, mas ainda não possui data de publicação."
                                .formatted(edicao.getNumero(), nomeSerie(serie)),
                        ORIGEM_BANCO_LOCAL,
                        Map.of("serieId", serie.getId(), "edicaoId", edicao.getId()));
            }

            Map<String, Object> dados = new LinkedHashMap<>();
            dados.put("serieId", serie.getId());
            dados.put("edicaoId", edicao.getId());
            dados.put("numero", edicao.getNumero());
            dados.put("data", data);
            dados.put("campoUsado", campoUsado);
            String resposta = "A edição nº %s de %s foi publicada em %s."
                    .formatted(edicao.getNumero(), nomeSerie(serie), data.format(FORMATO_DATA));
            return new RespostaAssistenteDTO(resposta, ORIGEM_BANCO_LOCAL, dados);
        }

        Integer anoInicio = serie.getAnoInicio();
        Integer anoFim = serie.getAnoFim();
        if (anoInicio == null) {
            LocalDate primeiraData = edicaoRepository.buscarTodosComBusca(serie.getId(), null).stream()
                    .map(edicao -> edicao.getDataPublicacao() != null
                            ? edicao.getDataPublicacao()
                            : edicao.getDataCobertura())
                    .filter(data -> data != null)
                    .min(LocalDate::compareTo)
                    .orElse(null);
            anoInicio = primeiraData != null ? primeiraData.getYear() : null;
        }

        if (anoInicio == null) {
            return new RespostaAssistenteDTO(
                    "%s está cadastrada, mas ainda não possui ano inicial nem datas de publicação nas edições."
                            .formatted(nomeSerie(serie)),
                    ORIGEM_BANCO_LOCAL,
                    Map.of("serieId", serie.getId()));
        }

        Map<String, Object> dados = new LinkedHashMap<>();
        dados.put("serieId", serie.getId());
        dados.put("anoInicio", anoInicio);
        dados.put("anoFim", anoFim);
        String periodo = anoFim != null && !anoFim.equals(anoInicio)
                ? "entre %d e %d".formatted(anoInicio, anoFim)
                : "em %d".formatted(anoInicio);
        return new RespostaAssistenteDTO(
                "%s foi publicada %s.".formatted(nomeSerie(serie), periodo),
                ORIGEM_BANCO_LOCAL,
                dados);
    }

    private RespostaAssistenteDTO responderCreditosCatalogo(String pergunta, String perguntaNormalizada) {
        Optional<Serie> serieEncontrada = localizarSerie(pergunta);
        if (serieEncontrada.isEmpty()) {
            if (localizarCriador(pergunta).isPresent()) {
                return responderCriador(pergunta);
            }
            return respostaSerieNaoEncontrada();
        }

        Serie serie = serieEncontrada.get();
        String numeroEdicao = extrairNumeroEdicao(pergunta);
        List<CreditoEdicaoRespostaDTO> creditos;
        Edicao edicao = null;
        if (numeroEdicao != null) {
            Optional<Edicao> edicaoEncontrada = edicaoRepository.buscarPorNumeroESerie(numeroEdicao, serie.getId());
            if (edicaoEncontrada.isEmpty()) {
                return respostaEdicaoNaoEncontrada(serie, numeroEdicao);
            }
            edicao = edicaoEncontrada.get();
            creditos = creditoEdicaoService.listarPorEdicao(edicao.getId());
        } else {
            creditos = creditoEdicaoService.listarPorSerie(serie.getId());
        }

        Set<PapelCriador> papeis = papeisSolicitados(perguntaNormalizada);
        List<CreditoEdicaoRespostaDTO> creditosFiltrados = creditos.stream()
                .filter(credito -> papeis.isEmpty() || papeis.contains(credito.papel()))
                .toList();
        String alvo = edicao == null
                ? nomeSerie(serie)
                : "%s, edição nº %s".formatted(nomeSerie(serie), edicao.getNumero());

        if (creditosFiltrados.isEmpty()) {
            String tipoCredito = papeis.isEmpty()
                    ? "créditos"
                    : papeis.stream().map(this::nomePapel).reduce((a, b) -> a + "/" + b).orElse("créditos");
            return new RespostaAssistenteDTO(
                    "%s está cadastrada, mas ainda não possui crédito de %s no catálogo."
                            .formatted(alvo, tipoCredito),
                    ORIGEM_BANCO_LOCAL,
                    List.of());
        }

        Map<PapelCriador, Set<String>> nomesPorPapel = new LinkedHashMap<>();
        for (CreditoEdicaoRespostaDTO credito : creditosFiltrados) {
            if (credito.criador() == null || credito.criador().nome() == null) {
                continue;
            }
            nomesPorPapel.computeIfAbsent(credito.papel(), chave -> new LinkedHashSet<>())
                    .add(nomeCriador(credito));
        }

        String resumo = nomesPorPapel.entrySet().stream()
                .map(entrada -> "%s: %s".formatted(
                        nomePapel(entrada.getKey()),
                        String.join(", ", entrada.getValue())))
                .reduce((a, b) -> a + "; " + b)
                .orElse("créditos sem nome de criador");
        String resposta = "Créditos cadastrados para %s — %s.".formatted(alvo, resumo);
        return new RespostaAssistenteDTO(resposta, ORIGEM_BANCO_LOCAL, creditosFiltrados);
    }

    private RespostaAssistenteDTO responderDetalhesEdicao(String pergunta) {
        Optional<Serie> serieEncontrada = localizarSerie(pergunta);
        if (serieEncontrada.isEmpty()) {
            return respostaSerieNaoEncontrada();
        }

        Serie serie = serieEncontrada.get();
        String numeroEdicao = extrairNumeroEdicao(pergunta);
        if (numeroEdicao == null) {
            return new RespostaAssistenteDTO(
                    "Informe o número da edição que deseja consultar, por exemplo: %s edição nº 1."
                            .formatted(nomeSerie(serie)),
                    ORIGEM_NAO_ENCONTRADO,
                    Map.of("serieId", serie.getId()));
        }

        Optional<Edicao> edicaoEncontrada = edicaoRepository.buscarPorNumeroESerie(numeroEdicao, serie.getId());
        if (edicaoEncontrada.isEmpty()) {
            return respostaEdicaoNaoEncontrada(serie, numeroEdicao);
        }

        Edicao edicao = edicaoEncontrada.get();
        String titulo = edicao.getTitulo() == null || edicao.getTitulo().isBlank()
                ? "sem subtítulo cadastrado"
                : edicao.getTitulo();
        String data = edicao.getDataPublicacao() == null
                ? "data não cadastrada"
                : edicao.getDataPublicacao().format(FORMATO_DATA);
        String paginas = edicao.getQuantidadePaginas() == null
                ? "páginas não cadastradas"
                : "%d páginas".formatted(edicao.getQuantidadePaginas());
        String formato = edicao.getFormato() == null || edicao.getFormato().isBlank()
                ? "formato não cadastrado"
                : edicao.getFormato();
        String preco = edicao.getPrecoCapa() == null
                ? "preço de capa não cadastrado"
                : "preço de capa R$ %s".formatted(edicao.getPrecoCapa().toPlainString());
        String capa = edicao.getUrlCapa() == null || edicao.getUrlCapa().isBlank()
                ? "sem capa cadastrada"
                : "com capa cadastrada";

        String resposta = "%s, edição nº %s — %s; publicação: %s; %s; %s; %s; %s."
                .formatted(nomeSerie(serie), edicao.getNumero(), titulo, data, paginas, formato, preco, capa);
        return new RespostaAssistenteDTO(resposta, ORIGEM_BANCO_LOCAL, dadosEdicao(edicao));
    }

    private RespostaAssistenteDTO responderListagemEdicoes(String pergunta) {
        Optional<Serie> serieEncontrada = localizarSerie(pergunta);
        if (serieEncontrada.isEmpty()) {
            return respostaSerieNaoEncontrada();
        }

        Serie serie = serieEncontrada.get();
        List<Edicao> edicoes = edicaoRepository.buscarTodosComBusca(serie.getId(), null).stream()
                .sorted(Comparator.comparing(Edicao::getNumero, Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER)))
                .toList();
        if (edicoes.isEmpty()) {
            return new RespostaAssistenteDTO(
                    "%s está cadastrada, mas ainda não possui edições.".formatted(nomeSerie(serie)),
                    ORIGEM_BANCO_LOCAL,
                    List.of());
        }

        List<Map<String, Object>> dados = edicoes.stream().map(this::dadosEdicao).toList();
        String numeros = edicoes.stream()
                .limit(30)
                .map(Edicao::getNumero)
                .reduce((a, b) -> a + ", " + b)
                .orElse("");
        if (edicoes.size() > 30) {
            numeros += " e mais %d".formatted(edicoes.size() - 30);
        }
        String resposta = "%s possui %s: %s."
                .formatted(nomeSerie(serie), quantidadeEdicoes(edicoes.size()), numeros);
        return new RespostaAssistenteDTO(resposta, ORIGEM_BANCO_LOCAL, dados);
    }

    private RespostaAssistenteDTO responderFichaSerie(String pergunta) {
        Optional<Serie> serieEncontrada = localizarSerie(pergunta);
        if (serieEncontrada.isEmpty()) {
            return respostaSerieNaoEncontrada();
        }

        Serie serie = serieEncontrada.get();
        long totalEdicoes = edicaoRepository.contarPorSerie(serie.getId());
        Map<String, Object> dados = dadosContagemSerie(serie, totalEdicoes);
        dados.put("anoInicio", serie.getAnoInicio());
        dados.put("anoFim", serie.getAnoFim());
        dados.put("descricao", serie.getDescricao());

        String periodo = serie.getAnoInicio() == null
                ? "ano inicial não cadastrado"
                : serie.getAnoFim() != null && !serie.getAnoFim().equals(serie.getAnoInicio())
                        ? "%d–%d".formatted(serie.getAnoInicio(), serie.getAnoFim())
                        : String.valueOf(serie.getAnoInicio());
        String resposta = "%s — editora: %s; período: %s; %s cadastrada(s)."
                .formatted(
                        nomeSerie(serie),
                        serie.getEditora() != null ? serie.getEditora().getNome() : "não cadastrada",
                        periodo,
                        quantidadeEdicoes((int) totalEdicoes));
        return new RespostaAssistenteDTO(resposta, ORIGEM_BANCO_LOCAL, dados);
    }

    private RespostaAssistenteDTO responderQuantidadeEdicoesSerie(String pergunta) {
        String assunto = extrairAssuntoQuantidade(pergunta);
        if (assunto.isBlank()) {
            return respostaSerieNaoEncontrada();
        }

        List<Edicao> edicoes = edicaoRepository.buscarTodosComBusca(null, assunto);
        if (edicoes.isEmpty()) {
            return new RespostaAssistenteDTO(
                    "Nao encontrei edicoes cadastradas relacionadas a \"%s\" no catalogo do HQ-HUB."
                            .formatted(assunto),
                    ORIGEM_NAO_ENCONTRADO,
                    null);
        }

        Map<Long, Serie> series = new LinkedHashMap<>();
        Map<Long, Long> totaisPorSerie = new LinkedHashMap<>();
        for (Edicao edicao : edicoes) {
            Serie serie = edicao.getSerie();
            series.putIfAbsent(serie.getId(), serie);
            totaisPorSerie.merge(serie.getId(), 1L, Long::sum);
        }

        List<Map<String, Object>> distribuicao = series.entrySet().stream()
                .map(entrada -> dadosContagemSerie(entrada.getValue(), totaisPorSerie.get(entrada.getKey())))
                .toList();

        String resposta;
        if (distribuicao.size() == 1) {
            Serie serie = series.values().iterator().next();
            String volume = serie.getVolume() != null ? " V%d".formatted(serie.getVolume()) : "";
            String editora = serie.getEditora() != null ? " pela %s".formatted(serie.getEditora().getNome()) : "";
            String cadastradas = edicoes.size() == 1 ? "cadastrada" : "cadastradas";
            resposta = "%s%s tem %s %s no HQ-HUB%s."
                    .formatted(serie.getTitulo(), volume, quantidadeEdicoes(edicoes.size()), cadastradas, editora);
        } else {
            String destaques = distribuicao.stream()
                    .limit(5)
                    .map(item -> "%s: %s".formatted(item.get("titulo"), item.get("totalEdicoes")))
                    .reduce((primeiro, proximo) -> primeiro + "; " + proximo)
                    .orElse("");
            String quantidadeTitulos = distribuicao.size() == 1
                    ? "1 título"
                    : "%d títulos".formatted(distribuicao.size());
            resposta = "Encontrei %s relacionadas a \"%s\" no HQ-HUB, distribuídas em %s. %s%s"
                    .formatted(
                            quantidadeEdicoes(edicoes.size()),
                            assunto,
                            quantidadeTitulos,
                            destaques,
                            distribuicao.size() > 5 ? "; e mais %d títulos.".formatted(distribuicao.size() - 5) : ".");
        }

        Map<String, Object> dados = new LinkedHashMap<>();
        dados.put("consulta", assunto);
        dados.put("totalEdicoes", edicoes.size());
        dados.put("totalTitulos", distribuicao.size());
        dados.put("titulos", distribuicao);

        return new RespostaAssistenteDTO(resposta, ORIGEM_BANCO_LOCAL, dados);
    }

    private Map<String, Object> dadosContagemSerie(Serie serie, long totalEdicoes) {
        Map<String, Object> dados = new LinkedHashMap<>();
        dados.put("serieId", serie.getId());
        dados.put("titulo", serie.getTitulo());
        dados.put("volume", serie.getVolume());
        dados.put("editora", serie.getEditora() != null ? serie.getEditora().getNome() : null);
        dados.put("totalEdicoes", totalEdicoes);
        return dados;
    }

    private String quantidadeEdicoes(int quantidade) {
        return quantidade == 1 ? "1 edição" : "%d edições".formatted(quantidade);
    }

    private String extrairAssuntoQuantidade(String pergunta) {
        StringBuilder assunto = new StringBuilder();
        for (String token : pergunta.split("[^\\p{L}\\p{N}]+")) {
            if (token.isBlank() || TERMOS_PERGUNTA_QUANTIDADE.contains(normalizar(token))) {
                continue;
            }
            if (!assunto.isEmpty()) {
                assunto.append(' ');
            }
            assunto.append(token);
        }
        return assunto.toString().trim();
    }

    private Optional<Serie> localizarSerie(String pergunta) {
        Optional<Long> id = extrairId(pergunta);
        if (id.isPresent()) {
            return serieRepository.findByIdOptional(id.get());
        }

        String perguntaNormalizada = normalizar(pergunta);
        List<Serie> candidatas = serieRepository.listAll()
                .stream()
                .filter(serie -> perguntaNormalizada.contains(normalizar(serie.getTitulo())))
                .sorted((primeira, segunda) -> Integer.compare(segunda.getTitulo().length(), primeira.getTitulo().length()))
                .toList();

        if (!candidatas.isEmpty()) {
            int maiorTitulo = normalizar(candidatas.get(0).getTitulo()).length();
            candidatas = candidatas.stream()
                    .filter(serie -> normalizar(serie.getTitulo()).length() == maiorTitulo)
                    .toList();

            List<Serie> brasileiras = candidatas.stream()
                    .filter(serie -> serie.getTipoSerie() == TipoSerie.BRASILEIRA)
                    .toList();
            if (!brasileiras.isEmpty()) {
                candidatas = brasileiras;
            }

            Matcher volumeEncontrado = PADRAO_VOLUME.matcher(pergunta);
            if (volumeEncontrado.find()) {
                int volume = Integer.parseInt(volumeEncontrado.group(1));
                List<Serie> peloVolume = candidatas.stream()
                        .filter(serie -> serie.getVolume() != null && serie.getVolume() == volume)
                        .toList();
                if (!peloVolume.isEmpty()) {
                    candidatas = peloVolume;
                }
            }

            List<Serie> pelaEditora = candidatas.stream()
                    .filter(serie -> serie.getEditora() != null
                            && perguntaNormalizada.contains(normalizar(serie.getEditora().getNome())))
                    .toList();
            if (!pelaEditora.isEmpty()) {
                candidatas = pelaEditora;
            }

            return candidatas.stream().findFirst();
        }

        return serieRepository.buscarPaginado(pergunta, 0, 5)
                .stream()
                .findFirst();
    }

    private Optional<Criador> localizarCriador(String pergunta) {
        String perguntaNormalizada = normalizar(pergunta);
        return criadorRepository.listAll()
                .stream()
                .filter(criador -> perguntaNormalizada.contains(normalizar(criador.getNome()))
                        || (criador.getNomeArtistico() != null
                                && perguntaNormalizada.contains(normalizar(criador.getNomeArtistico()))))
                .findFirst();
    }

    private Optional<Long> extrairId(String pergunta) {
        Matcher matcher = PADRAO_ID.matcher(pergunta);
        if (!matcher.find()) {
            return Optional.empty();
        }

        return Optional.of(Long.valueOf(matcher.group(1)));
    }

    private Integer extrairAno(String pergunta) {
        Matcher matcher = PADRAO_ANO.matcher(pergunta);
        return matcher.find() ? Integer.valueOf(matcher.group(1)) : null;
    }

    private String extrairNumeroEdicao(String pergunta) {
        Matcher matcher = PADRAO_NUMERO_EDICAO.matcher(pergunta);
        return matcher.find() ? matcher.group(1) : null;
    }

    private String nomeSerie(Serie serie) {
        String volume = serie.getVolume() != null ? " V%d".formatted(serie.getVolume()) : "";
        String editora = serie.getEditora() != null ? " (%s)".formatted(serie.getEditora().getNome()) : "";
        return serie.getTitulo() + volume + editora;
    }

    private RespostaAssistenteDTO respostaEdicaoNaoEncontrada(Serie serie, String numero) {
        return new RespostaAssistenteDTO(
                "Não encontrei a edição nº %s em %s.".formatted(numero, nomeSerie(serie)),
                ORIGEM_NAO_ENCONTRADO,
                null);
    }

    private Map<String, Object> dadosEdicao(Edicao edicao) {
        Map<String, Object> dados = new LinkedHashMap<>();
        dados.put("id", edicao.getId());
        dados.put("numero", edicao.getNumero());
        dados.put("titulo", edicao.getTitulo());
        dados.put("nomeVolume", edicao.getNomeVolume());
        dados.put("descricao", edicao.getDescricao());
        dados.put("dataCobertura", edicao.getDataCobertura());
        dados.put("dataPublicacao", edicao.getDataPublicacao());
        dados.put("dataDisponibilidadeLoja", edicao.getDataDisponibilidadeLoja());
        dados.put("quantidadePaginas", edicao.getQuantidadePaginas());
        dados.put("precoCapa", edicao.getPrecoCapa());
        dados.put("formato", edicao.getFormato());
        dados.put("codigoBarras", edicao.getCodigoBarras());
        dados.put("urlCapa", edicao.getUrlCapa());
        return dados;
    }

    private String nomeCriador(CreditoEdicaoRespostaDTO credito) {
        String nomeArtistico = credito.criador().nomeArtistico();
        return nomeArtistico != null && !nomeArtistico.isBlank()
                ? nomeArtistico
                : credito.criador().nome();
    }

    private Set<PapelCriador> papeisSolicitados(String perguntaNormalizada) {
        Set<PapelCriador> papeis = EnumSet.noneOf(PapelCriador.class);
        if (contemAlguma(perguntaNormalizada, "autor", "roteir", "escreveu", "escrito por", "texto de")) {
            papeis.add(PapelCriador.ROTEIRO);
        }
        if (contemAlguma(perguntaNormalizada, "desenhou", "desenhista", "ilustrou", "ilustrador")) {
            papeis.add(PapelCriador.DESENHO);
            papeis.add(PapelCriador.ARTE);
        }
        if (contemAlguma(perguntaNormalizada, "arte final", "arte-final", "arte finalista")) {
            papeis.add(PapelCriador.ARTE_FINAL);
        } else if (contemAlguma(perguntaNormalizada, "arte", "artista")) {
            papeis.add(PapelCriador.ARTE);
            papeis.add(PapelCriador.DESENHO);
        }
        if (contemAlguma(perguntaNormalizada, "capista", "fez a capa", "arte da capa", "creditos de capa")) {
            papeis.add(PapelCriador.CAPA);
        }
        if (contemAlguma(perguntaNormalizada, "colorista", "cores", "coloriu")) {
            papeis.add(PapelCriador.CORES);
        }
        if (contemAlguma(perguntaNormalizada, "letrista", "letras")) {
            papeis.add(PapelCriador.LETRAS);
        }
        if (contemAlguma(perguntaNormalizada, "editor", "editou")) {
            papeis.add(PapelCriador.EDITOR);
        }
        return papeis;
    }

    private String nomePapel(PapelCriador papel) {
        return switch (papel) {
            case ROTEIRO -> "roteiro";
            case ARTE -> "arte";
            case DESENHO -> "desenho";
            case ARTE_FINAL -> "arte-final";
            case CORES -> "cores";
            case LETRAS -> "letras";
            case CAPA -> "capa";
            case EDITOR -> "edição";
            case OUTRO -> "outro";
        };
    }

    private Integer extrairMes(String perguntaNormalizada) {
        String[] meses = {
                "janeiro", "fevereiro", "marco", "abril", "maio", "junho",
                "julho", "agosto", "setembro", "outubro", "novembro", "dezembro"
        };

        for (int indice = 0; indice < meses.length; indice++) {
            if (perguntaNormalizada.contains(meses[indice])) {
                return indice + 1;
            }
        }

        Matcher matcher = Pattern.compile("\\b(1[0-2]|0?[1-9])\\b").matcher(perguntaNormalizada);
        return matcher.find() ? Integer.valueOf(matcher.group(1)) : null;
    }

    private boolean contemAlguma(String texto, String... termos) {
        for (String termo : termos) {
            if (texto.contains(termo)) {
                return true;
            }
        }

        return false;
    }

    private boolean ehPerguntaResumoColecao(String perguntaNormalizada) {
        return contemAlguma(perguntaNormalizada,
                "resumo",
                "visao geral",
                "panorama",
                "overview",
                "como esta minha colecao",
                "como esta a minha colecao",
                "valor total que ja paguei",
                "valor total pago");
    }

    private boolean ehPerguntaQuantidadeEdicoes(String perguntaNormalizada) {
        return contemAlguma(perguntaNormalizada,
                "quantas edicoes",
                "quantos numeros",
                "quantas revistas",
                "quantas hqs",
                "quantos volumes",
                "total de edicoes",
                "total de numeros",
                "total de revistas");
    }

    private boolean ehPerguntaTotaisCatalogo(String perguntaNormalizada) {
        return contemAlguma(perguntaNormalizada,
                "quantos titulos",
                "quantas series",
                "total de titulos",
                "total de series",
                "numero de titulos",
                "numero de series");
    }

    private boolean ehPerguntaDataCatalogo(String perguntaNormalizada) {
        return contemAlguma(perguntaNormalizada,
                "em que ano",
                "qual o ano",
                "quando foi lancad",
                "quando foi publicad",
                "quando saiu",
                "data de publicacao",
                "data da publicacao",
                "ano de lancamento",
                "ano da publicacao");
    }

    private boolean ehPerguntaCreditosCatalogo(String perguntaNormalizada) {
        return contemAlguma(perguntaNormalizada,
                "quem escreveu",
                "quem desenhou",
                "quem ilustrou",
                "quem fez a arte",
                "quem fez a capa",
                "quem coloriu",
                "quem editou",
                "quem e o autor",
                "quem foi o autor",
                "autor de",
                "autor da",
                "autor do",
                "roteirista de",
                "roteirista da",
                "roteirista do",
                "desenhista de",
                "desenhista da",
                "desenhista do",
                "creditos de",
                "creditos da",
                "creditos do");
    }

    private boolean ehPerguntaDetalhesEdicao(String perguntaNormalizada) {
        return contemAlguma(perguntaNormalizada,
                "detalhes da edicao",
                "dados da edicao",
                "ficha da edicao",
                "informacoes da edicao",
                "quantas paginas",
                "numero de paginas",
                "preco de capa",
                "qual o preco",
                "qual formato",
                "qual o formato",
                "codigo de barras",
                "tem capa",
                "possui capa");
    }

    private boolean ehPerguntaListagemEdicoes(String perguntaNormalizada) {
        return contemAlguma(perguntaNormalizada,
                "quais edicoes",
                "liste as edicoes",
                "listar edicoes",
                "mostre as edicoes",
                "quais numeros",
                "lista de edicoes");
    }

    private boolean ehPerguntaFichaSerie(String perguntaNormalizada) {
        return contemAlguma(perguntaNormalizada,
                "ficha da serie",
                "ficha do titulo",
                "dados da serie",
                "dados do titulo",
                "detalhes da serie",
                "detalhes do titulo",
                "informacoes da serie",
                "informacoes do titulo",
                "qual editora",
                "quem publicou",
                "qual o volume da serie");
    }

    private boolean ehPerguntaImportacaoGuiaBloqueada(String perguntaNormalizada) {
        boolean falaDoGuiaOuRobo = contemAlguma(perguntaNormalizada,
                "guia dos quadrinhos",
                "guiadosquadrinhos",
                "robo_importador_texto",
                "robo importador",
                "importador texto",
                "importacao pelo guia",
                "importar pelo guia",
                "txt do guia");
        boolean falaDeBloqueioOuTxt = contemAlguma(perguntaNormalizada,
                "403",
                "forbidden",
                "cloudflare",
                "bloqueio",
                "bloqueado",
                "nao baixa",
                "nao puxou",
                "nao conseguiu baixar",
                "copiar texto",
                "arquivo txt",
                "--entrada",
                "--url");

        return falaDoGuiaOuRobo && falaDeBloqueioOuTxt;
    }

    private RespostaAssistenteDTO responderImportacaoGuiaBloqueada() {
        String resposta = String.join("\n",
                "Quando o Guia dos Quadrinhos bloqueia o robo com HTTP 403, Forbidden ou Cloudflare, o problema nao e o caminho do PowerShell.",
                "O site bloqueou a leitura automatica por URL. Nesse caso, use o fluxo manual com TXT:",
                "",
                "1. Abra a pagina do Guia no navegador.",
                "2. Use Ctrl+A e Ctrl+C para copiar o conteudo da pagina.",
                "3. Na raiz do HQ-HUB, crie o TXT:",
                "mkdir docs\\importacao\\rascunhos\\NOME-DA-PASTA",
                "notepad docs\\importacao\\rascunhos\\NOME-DA-PASTA\\entrada-guia.txt",
                "",
                "4. Cole o texto no Notepad, salve e feche.",
                "5. Rode o importador usando --entrada, nao --url:",
                "python docs\\importacao\\ferramentas\\fluxo-essencial-hqhub\\robo_importador_texto.py `",
                "  --entrada \"docs\\importacao\\rascunhos\\NOME-DA-PASTA\\entrada-guia.txt\" `",
                "  --saida \"docs\\importacao\\rascunhos\\NOME-DA-PASTA\\saida-base-guia.json\" `",
                "  --titulo-serie \"Titulo da serie\" `",
                "  --fase \"1a Serie\" `",
                "  --editora \"Panini\" `",
                "  --volume 1",
                "",
                "Exemplo para Dinossauro Demonio por Jack Kirby:",
                "python docs\\importacao\\ferramentas\\fluxo-essencial-hqhub\\robo_importador_texto.py `",
                "  --entrada \"docs\\importacao\\rascunhos\\marvel-omnibus\\dinossauro-demonio-guia.txt\" `",
                "  --saida \"docs\\importacao\\rascunhos\\marvel-omnibus\\dinossauro-demonio-base-guia.json\" `",
                "  --titulo-serie \"Dinossauro Demonio por Jack Kirby\" `",
                "  --fase \"1a Serie\" `",
                "  --editora \"Panini\" `",
                "  --volume 1",
                "",
                "Dica de PowerShell: o acento grave (`) precisa ser o ultimo caractere da linha, sem espaco depois dele.");

        Map<String, Object> dados = new LinkedHashMap<>();
        dados.put("motivo", "Guia bloqueia acesso automatico com 403/Cloudflare");
        dados.put("alternativa", "Copiar pagina no navegador e usar robo_importador_texto.py com --entrada");

        return new RespostaAssistenteDTO(resposta, ORIGEM_CONHECIMENTO_ESSENCIAL, dados);
    }

    private boolean ehPerguntaSobreSistema(String perguntaNormalizada) {
        return contemAlguma(perguntaNormalizada,
                "hq-hub",
                "hqhub",
                "sistema",
                "app",
                "aplicativo",
                "funciona",
                "como faco",
                "como usar",
                "onde cadastro",
                "onde vejo",
                "catalogo",
                "colecao",
                "estante",
                "compras",
                "amigos",
                "mensagens",
                "importacao",
                "revisao");
    }

    private RespostaAssistenteDTO responderAjudaSistema() {
        return new RespostaAssistenteDTO(
                "Posso ajudar com o funcionamento do HQ-HUB e consultar o catálogo. Exemplos: quantos títulos existem?, em que ano Batman V1 foi lançado?, quem escreveu Batman edição nº 1?, quais edições existem em uma série? e mostre a ficha do título. Também respondo sobre coleção, faltantes, completude, compras, continuidade e importação.",
                ORIGEM_CONHECIMENTO_ESSENCIAL,
                null);
    }

    private String normalizar(String texto) {
        String semAcentos = Normalizer.normalize(texto, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "");
        return semAcentos.toLowerCase().trim();
    }

    private RespostaAssistenteDTO respostaSerieNaoEncontrada() {
        return new RespostaAssistenteDTO(
                "Não encontrei essa série no catálogo local. Informe o título exatamente como foi cadastrado ou use o id da série, por exemplo: serieId=1.",
                ORIGEM_NAO_ENCONTRADO,
                null);
    }

    private RespostaAssistenteDTO responderComConhecimentoEditorial(List<ResultadoBuscaConhecimentoDTO> resultados) {
        if (resultados.isEmpty()) {
            return new RespostaAssistenteDTO(
                    "Não encontrei conhecimento disponível sobre esse tema.",
                    ORIGEM_CONHECIMENTO_EDITORIAL,
                    null);
        }

        ResultadoBuscaConhecimentoDTO top = resultados.get(0);
        String resposta = top.conteudo() + "\n\n📌 Fonte: " + (top.fonte() != null ? top.fonte() : "Base Editorial HQ-HUB");
        
        if (top.urlFonte() != null && !top.urlFonte().isEmpty()) {
            resposta += " - " + top.urlFonte();
        }
        
        resposta += "\n🎯 Confiança: " + top.confianca();

        if (ehConhecimentoDeHeroi(top)) {
            resposta += PREFERENCIA_TEX;
        }

        return new RespostaAssistenteDTO(resposta, ORIGEM_CONHECIMENTO_EDITORIAL, resultados);
    }

    private Optional<RespostaAssistenteDTO> responderComConhecimentoEssencial(String perguntaNormalizada) {
        return CONHECIMENTOS_ESSENCIAIS.entrySet()
                .stream()
                .filter(entrada -> perguntaNormalizada.contains(entrada.getKey()))
                .findFirst()
                .map(entrada -> new RespostaAssistenteDTO(
                        entrada.getValue() + PREFERENCIA_TEX,
                        ORIGEM_CONHECIMENTO_ESSENCIAL,
                        null));
    }

    private boolean ehConhecimentoDeHeroi(ResultadoBuscaConhecimentoDTO resultado) {
        return "HEROI".equalsIgnoreCase(resultado.tipo());
    }

    private static Map<String, String> criarConhecimentosEssenciais() {
        Map<String, String> conhecimentos = new LinkedHashMap<>();
        conhecimentos.put(
                "batman",
                "Batman e o alter ego de Bruce Wayne, criado por Bob Kane e Bill Finger. Ele apareceu pela primeira vez em Detective Comics #27, em 1939, e e um dos principais personagens da DC Comics.");
        conhecimentos.put(
                "superman",
                "Superman e o alter ego de Clark Kent/Kal-El, criado por Jerry Siegel e Joe Shuster. Ele estreou em Action Comics #1, em 1938, e se tornou um dos simbolos centrais dos super-herois.");
        conhecimentos.put(
                "homem aranha",
                "Homem-Aranha e o alter ego de Peter Parker, criado por Stan Lee e Steve Ditko. Ele apareceu pela primeira vez em Amazing Fantasy #15, em 1962, pela Marvel Comics.");
        conhecimentos.put("spider man", conhecimentos.get("homem aranha"));
        conhecimentos.put(
                "universo marvel",
                "Para conhecer o universo Marvel, nao tente comecar pela cronologia inteira. Comece por historias fechadas ou fases com bom ponto de entrada: Homem-Aranha: A Ultima Cacada de Kraven, X-Men: Deus Ama, o Homem Mata, Marvels, Demolidor: O Diabo da Guarda, Demolidor de Frank Miller, Vingadores de Jonathan Hickman ou alguma fase recente da Panini como Nova Marvel/Fresh Start. Se quiser algo mais simples, escolha um personagem que voce gosta e leia um encadernado fechado antes de entrar em eventos grandes.");
        conhecimentos.put("marvel", conhecimentos.get("universo marvel"));
        conhecimentos.put(
                "comecar a ler quadrinhos",
                "Para comecar a ler quadrinhos, escolha uma historia fechada ou um arco famoso, sem tentar entender toda a cronologia de uma vez. Encadernados e graphic novels costumam ser melhores portas de entrada que eventos enormes. Boas escolhas sao Batman: Ano Um, Grandes Astros Superman, Homem-Aranha: A Ultima Cacada de Kraven, X-Men: Deus Ama, o Homem Mata, Demolidor: O Diabo da Guarda, Watchmen, Sandman ou uma colecao recente de personagem que voce ja goste.");
        conhecimentos.put("por onde comecar", conhecimentos.get("comecar a ler quadrinhos"));
        conhecimentos.put("por qual hq eu comeco", conhecimentos.get("comecar a ler quadrinhos"));
        return conhecimentos;
    }
}
