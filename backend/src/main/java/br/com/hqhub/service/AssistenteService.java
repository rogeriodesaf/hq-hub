package br.com.hqhub.service;

import java.text.Normalizer;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
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
import br.com.hqhub.entity.Serie;
import br.com.hqhub.repository.CriadorRepository;
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
    private static final Map<String, String> CONHECIMENTOS_ESSENCIAIS = criarConhecimentosEssenciais();

    private final ResumoColecaoService resumoColecaoService;
    private final FaltanteService faltanteService;
    private final CompraPlanejadaService compraPlanejadaService;
    private final CreditoEdicaoService creditoEdicaoService;
    private final RelacionamentoSerieService relacionamentoSerieService;
    private final ConhecimentoEditorialService conhecimentoEditorialService;
    private final SerieRepository serieRepository;
    private final CriadorRepository criadorRepository;

    public AssistenteService(
            ResumoColecaoService resumoColecaoService,
            FaltanteService faltanteService,
            CompraPlanejadaService compraPlanejadaService,
            CreditoEdicaoService creditoEdicaoService,
            RelacionamentoSerieService relacionamentoSerieService,
            ConhecimentoEditorialService conhecimentoEditorialService,
            SerieRepository serieRepository,
            CriadorRepository criadorRepository) {
        this.resumoColecaoService = resumoColecaoService;
        this.faltanteService = faltanteService;
        this.compraPlanejadaService = compraPlanejadaService;
        this.creditoEdicaoService = creditoEdicaoService;
        this.relacionamentoSerieService = relacionamentoSerieService;
        this.conhecimentoEditorialService = conhecimentoEditorialService;
        this.serieRepository = serieRepository;
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

        return new RespostaAssistenteDTO(
                "Ainda não encontrei uma intenção clara nessa pergunta. Por enquanto consigo responder sobre: resumo da coleção, edições faltantes, completude por série, compras planejadas, criadores, continuidade entre séries e curiosidades sobre quadrinhos (se disponíveis na base editorial).",
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

    private Optional<Serie> localizarSerie(String pergunta) {
        Optional<Long> id = extrairId(pergunta);
        if (id.isPresent()) {
            return serieRepository.findByIdOptional(id.get());
        }

        String perguntaNormalizada = normalizar(pergunta);
        return serieRepository.buscarPaginado(null, 0, 200)
                .stream()
                .filter(serie -> perguntaNormalizada.contains(normalizar(serie.getTitulo())))
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
        return conhecimentos;
    }
}
