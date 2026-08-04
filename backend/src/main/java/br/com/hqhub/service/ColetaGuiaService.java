package br.com.hqhub.service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import br.com.hqhub.dto.ColetaGuiaRespostaDTO;
import br.com.hqhub.dto.EdicaoImportacaoDTO;
import br.com.hqhub.dto.GeracaoRascunhoImportacaoDTO;
import br.com.hqhub.dto.ImportacaoCatalogoDTO;
import br.com.hqhub.entity.ColetaGuia;
import br.com.hqhub.entity.FonteColetaCatalogo;
import br.com.hqhub.entity.StatusColetaGuia;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.repository.ColetaGuiaRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class ColetaGuiaService {

    private static final int PAGINAS_POR_LOTE = 10;
    private static final int MAX_FALHAS_CONSECUTIVAS = 3;
    private static final long ESPERA_MINIMA_SEGUNDOS = 120;
    private static final long ESPERA_MAXIMA_SEGUNDOS = 300;

    private static final TypeReference<List<String>> LISTA_STRINGS = new TypeReference<>() {
    };
    private static final TypeReference<List<EdicaoImportacaoDTO>> LISTA_EDICOES = new TypeReference<>() {
    };

    private final ColetaGuiaRepository repository;
    private final GeracaoRascunhoImportacaoService gerador;
    private final UsuarioAutenticadoService usuarioAutenticadoService;
    private final ObjectMapper objectMapper;

    public ColetaGuiaService(
            ColetaGuiaRepository repository,
            GeracaoRascunhoImportacaoService gerador,
            UsuarioAutenticadoService usuarioAutenticadoService,
            ObjectMapper objectMapper) {
        this.repository = repository;
        this.gerador = gerador;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
        this.objectMapper = objectMapper;
    }

    @Transactional
    public ColetaGuiaRespostaDTO iniciar(GeracaoRascunhoImportacaoDTO pedido) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        GeracaoRascunhoImportacaoService.PreparacaoColeta preparacao = gerador.prepararColeta(pedido);

        ColetaGuia coleta = new ColetaGuia();
        coleta.setUsuario(usuario);
        coleta.setFonte(FonteColetaCatalogo.GUIA);
        coleta.setPedidoJson(escreverJson(pedido));
        coleta.setUrlsJson(escreverJson(preparacao.urls()));
        coleta.setEdicoesJson("[]");
        coleta.setAvisosJson(escreverJson(preparacao.avisos()));
        coleta.setTotalPaginas(preparacao.urls().size());
        coleta.setPaginasProcessadas(0);
        coleta.setPaginasNoLote(0);
        coleta.setFalhasConsecutivas(0);
        coleta.setStatus(preparacao.urls().isEmpty() ? StatusColetaGuia.PAUSADA : StatusColetaGuia.PRONTA);
        coleta.setMensagem(preparacao.urls().isEmpty()
                ? "Nenhuma pagina foi encontrada. Confira a URL e tente novamente."
                : "Coleta preparada. Iniciando a primeira pagina.");
        repository.persist(coleta);
        return paraResposta(coleta);
    }

    @Transactional
    public ColetaGuiaRespostaDTO processarProximaPagina(UUID id) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        ColetaGuia coleta = repository.buscarParaProcessamento(id, usuario.getId(), FonteColetaCatalogo.GUIA)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Coleta do Guia nao encontrada."));

        if (coleta.getStatus() == StatusColetaGuia.CONCLUIDA || coleta.getStatus() == StatusColetaGuia.PAUSADA) {
            return paraResposta(coleta);
        }
        LocalDateTime agora = LocalDateTime.now();
        if (coleta.getProximaExecucao() != null && coleta.getProximaExecucao().isAfter(agora)) {
            coleta.setStatus(StatusColetaGuia.AGUARDANDO);
            return paraResposta(coleta);
        }

        List<String> urls = lerJson(coleta.getUrlsJson(), LISTA_STRINGS);
        List<EdicaoImportacaoDTO> edicoes = new ArrayList<>(lerJson(coleta.getEdicoesJson(), LISTA_EDICOES));
        List<String> avisos = new ArrayList<>(lerJson(coleta.getAvisosJson(), LISTA_STRINGS));
        GeracaoRascunhoImportacaoDTO pedido = lerJson(coleta.getPedidoJson(), GeracaoRascunhoImportacaoDTO.class);

        if (coleta.getPaginasProcessadas() >= urls.size()) {
            concluir(coleta, pedido, urls, edicoes, avisos);
            return paraResposta(coleta);
        }

        String url = urls.get(coleta.getPaginasProcessadas());
        coleta.setStatus(StatusColetaGuia.PROCESSANDO);
        coleta.setMensagem("Processando pagina " + (coleta.getPaginasProcessadas() + 1) + " de " + urls.size() + ".");

        try {
            edicoes.add(gerador.coletarEdicao(url, pedido.editora(), avisos));
            coleta.setPaginasProcessadas(coleta.getPaginasProcessadas() + 1);
            coleta.setPaginasNoLote(coleta.getPaginasNoLote() + 1);
            coleta.setFalhasConsecutivas(0);
            coleta.setEdicoesJson(escreverJson(edicoes));
            coleta.setAvisosJson(escreverJson(avisos));

            if (coleta.getPaginasProcessadas() >= urls.size()) {
                concluir(coleta, pedido, urls, edicoes, avisos);
            } else if (coleta.getPaginasNoLote() >= PAGINAS_POR_LOTE) {
                agendarEspera(coleta, "Lote de 10 paginas concluido.");
                coleta.setPaginasNoLote(0);
            } else {
                coleta.setStatus(StatusColetaGuia.PRONTA);
                coleta.setProximaExecucao(null);
                coleta.setMensagem("Pagina concluida. Preparando a proxima.");
            }
        } catch (Exception erro) {
            if (erro instanceof InterruptedException) {
                Thread.currentThread().interrupt();
            }
            int falhas = coleta.getFalhasConsecutivas() + 1;
            coleta.setFalhasConsecutivas(falhas);
            avisos.add("Falha ao acessar " + url + ": " + mensagemErro(erro));
            coleta.setAvisosJson(escreverJson(avisos));
            if (falhas >= MAX_FALHAS_CONSECUTIVAS) {
                coleta.setStatus(StatusColetaGuia.PAUSADA);
                coleta.setProximaExecucao(null);
                coleta.setMensagem("A coleta foi pausada apos 3 falhas. Aguarde a liberacao do Guia e clique em Retomar.");
            } else {
                agendarEspera(coleta, "O Guia bloqueou ou nao respondeu.");
            }
        }

        return paraResposta(coleta);
    }

    public ColetaGuiaRespostaDTO buscar(UUID id) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        return paraResposta(repository.buscarPorUsuario(id, usuario.getId(), FonteColetaCatalogo.GUIA)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Coleta do Guia nao encontrada.")));
    }

    @Transactional
    public ColetaGuiaRespostaDTO retomar(UUID id) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        ColetaGuia coleta = repository.buscarParaProcessamento(id, usuario.getId(), FonteColetaCatalogo.GUIA)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Coleta do Guia nao encontrada."));
        if (coleta.getStatus() != StatusColetaGuia.CONCLUIDA) {
            coleta.setStatus(StatusColetaGuia.PRONTA);
            coleta.setFalhasConsecutivas(0);
            coleta.setProximaExecucao(null);
            coleta.setMensagem("Coleta retomada.");
        }
        return paraResposta(coleta);
    }

    private void concluir(
            ColetaGuia coleta,
            GeracaoRascunhoImportacaoDTO pedido,
            List<String> urls,
            List<EdicaoImportacaoDTO> edicoes,
            List<String> avisos) {
        ImportacaoCatalogoDTO resultado = gerador.montarResultado(pedido, urls, edicoes, avisos);
        coleta.setResultadoJson(escreverJson(resultado));
        coleta.setStatus(StatusColetaGuia.CONCLUIDA);
        coleta.setProximaExecucao(null);
        coleta.setMensagem("JSON gerado. Revise os dados antes de importar.");
    }

    private void agendarEspera(ColetaGuia coleta, String motivo) {
        long espera = ThreadLocalRandom.current().nextLong(
                ESPERA_MINIMA_SEGUNDOS, ESPERA_MAXIMA_SEGUNDOS + 1);
        coleta.setStatus(StatusColetaGuia.AGUARDANDO);
        coleta.setProximaExecucao(LocalDateTime.now().plusSeconds(espera));
        coleta.setMensagem(motivo + " Nova tentativa em " + Math.max(2, espera / 60) + " minuto(s).");
    }

    private ColetaGuiaRespostaDTO paraResposta(ColetaGuia coleta) {
        LocalDateTime agora = LocalDateTime.now();
        long segundos = coleta.getProximaExecucao() == null
                ? 0
                : Math.max(0, Duration.between(agora, coleta.getProximaExecucao()).toSeconds());
        return new ColetaGuiaRespostaDTO(
                coleta.getId(),
                coleta.getStatus().name(),
                coleta.getTotalPaginas(),
                coleta.getPaginasProcessadas(),
                coleta.getProximaExecucao(),
                segundos,
                coleta.getMensagem(),
                lerJson(coleta.getAvisosJson(), LISTA_STRINGS),
                coleta.getResultadoJson() == null
                        ? null
                        : lerJson(coleta.getResultadoJson(), ImportacaoCatalogoDTO.class));
    }

    private String mensagemErro(Exception erro) {
        return erro.getMessage() == null || erro.getMessage().isBlank()
                ? erro.getClass().getSimpleName()
                : erro.getMessage();
    }

    private String escreverJson(Object valor) {
        try {
            return objectMapper.writeValueAsString(valor);
        } catch (JsonProcessingException e) {
            throw new RegraNegocioException("Nao foi possivel salvar o progresso da coleta.");
        }
    }

    private <T> T lerJson(String json, Class<T> tipo) {
        try {
            return objectMapper.readValue(json, tipo);
        } catch (JsonProcessingException e) {
            throw new RegraNegocioException("O progresso salvo da coleta esta invalido.");
        }
    }

    private <T> T lerJson(String json, TypeReference<T> tipo) {
        try {
            return objectMapper.readValue(json, tipo);
        } catch (JsonProcessingException e) {
            throw new RegraNegocioException("O progresso salvo da coleta esta invalido.");
        }
    }
}
