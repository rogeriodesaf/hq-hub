package br.com.hqhub.service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import br.com.hqhub.dto.ColetaGuiaRespostaDTO;
import br.com.hqhub.dto.EdicaoImportacaoDTO;
import br.com.hqhub.dto.GeracaoRascunhoGcdDTO;
import br.com.hqhub.dto.ImportacaoCatalogoDTO;
import br.com.hqhub.dto.SerieGcdRespostaDTO;
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
public class ColetaGcdService {

    private static final int MAX_FALHAS = 3;
    private static final TypeReference<List<String>> STRINGS = new TypeReference<>() {};
    private static final TypeReference<List<EdicaoImportacaoDTO>> EDICOES = new TypeReference<>() {};

    private final ColetaGuiaRepository repository;
    private final GcdCatalogoService gcd;
    private final UsuarioAutenticadoService usuarioAutenticado;
    private final ObjectMapper mapper;

    public ColetaGcdService(ColetaGuiaRepository repository, GcdCatalogoService gcd,
            UsuarioAutenticadoService usuarioAutenticado, ObjectMapper mapper) {
        this.repository = repository;
        this.gcd = gcd;
        this.usuarioAutenticado = usuarioAutenticado;
        this.mapper = mapper;
    }

    public List<SerieGcdRespostaDTO> buscarSeries(String busca) {
        return gcd.buscarSeries(busca);
    }

    @Transactional
    public ColetaGuiaRespostaDTO iniciar(GeracaoRascunhoGcdDTO pedido) {
        Usuario usuario = usuarioAutenticado.obterUsuario();
        GcdCatalogoService.PreparacaoGcd preparacao = gcd.preparar(pedido);
        ColetaGuia coleta = new ColetaGuia();
        coleta.setUsuario(usuario);
        coleta.setFonte(FonteColetaCatalogo.GCD);
        coleta.setPedidoJson(json(pedido));
        coleta.setUrlsJson(json(preparacao.urls()));
        coleta.setEdicoesJson("[]");
        List<String> avisos = new ArrayList<>(preparacao.avisos());
        avisos.add(0, "Editora selecionada: " + preparacao.editora());
        coleta.setAvisosJson(json(avisos));
        coleta.setTotalPaginas(preparacao.urls().size());
        coleta.setPaginasProcessadas(0);
        coleta.setPaginasNoLote(0);
        coleta.setFalhasConsecutivas(0);
        coleta.setStatus(preparacao.urls().isEmpty() ? StatusColetaGuia.PAUSADA : StatusColetaGuia.PRONTA);
        coleta.setMensagem(preparacao.urls().isEmpty()
                ? "A serie selecionada nao possui edicoes ativas no GCD."
                : "Coleta preparada pela API oficial do GCD.");
        repository.persist(coleta);
        return resposta(coleta);
    }

    @Transactional
    public ColetaGuiaRespostaDTO processar(UUID id) {
        ColetaGuia coleta = obterComLock(id);
        if (coleta.getStatus() == StatusColetaGuia.CONCLUIDA || coleta.getStatus() == StatusColetaGuia.PAUSADA) {
            return resposta(coleta);
        }
        if (coleta.getProximaExecucao() != null && coleta.getProximaExecucao().isAfter(LocalDateTime.now())) {
            coleta.setStatus(StatusColetaGuia.AGUARDANDO);
            return resposta(coleta);
        }
        List<String> urls = ler(coleta.getUrlsJson(), STRINGS);
        List<EdicaoImportacaoDTO> edicoes = new ArrayList<>(ler(coleta.getEdicoesJson(), EDICOES));
        List<String> avisos = new ArrayList<>(ler(coleta.getAvisosJson(), STRINGS));
        GeracaoRascunhoGcdDTO pedido = ler(coleta.getPedidoJson(), GeracaoRascunhoGcdDTO.class);
        String editora = avisos.isEmpty() ? pedido.editora() : avisos.get(0).replace("Editora selecionada: ", "");

        if (coleta.getPaginasProcessadas() >= urls.size()) {
            concluir(coleta, pedido, editora, urls, edicoes, avisos);
            return resposta(coleta);
        }
        String url = urls.get(coleta.getPaginasProcessadas());
        coleta.setStatus(StatusColetaGuia.PROCESSANDO);
        try {
            edicoes.add(gcd.coletarEdicao(url, editora, avisos));
            coleta.setPaginasProcessadas(coleta.getPaginasProcessadas() + 1);
            coleta.setFalhasConsecutivas(0);
            coleta.setProximaExecucao(null);
            coleta.setEdicoesJson(json(edicoes));
            coleta.setAvisosJson(json(avisos));
            if (coleta.getPaginasProcessadas() >= urls.size()) {
                concluir(coleta, pedido, editora, urls, edicoes, avisos);
            } else {
                coleta.setStatus(StatusColetaGuia.PRONTA);
                coleta.setMensagem("Edicao " + coleta.getPaginasProcessadas() + " de " + urls.size() + " coletada.");
            }
        } catch (RuntimeException erro) {
            if (erro instanceof GcdCatalogoService.LimiteGcdException limite) {
                coleta.setStatus(StatusColetaGuia.AGUARDANDO);
                coleta.setProximaExecucao(LocalDateTime.now().plusSeconds(limite.segundos()));
                coleta.setMensagem("O GCD atingiu o limite de consultas. A coleta continuara automaticamente depois da espera.");
                return resposta(coleta);
            }
            int falhas = coleta.getFalhasConsecutivas() + 1;
            coleta.setFalhasConsecutivas(falhas);
            avisos.add("Falha em " + url + ": " + erro.getMessage());
            coleta.setAvisosJson(json(avisos));
            coleta.setStatus(falhas >= MAX_FALHAS ? StatusColetaGuia.PAUSADA : StatusColetaGuia.AGUARDANDO);
            coleta.setProximaExecucao(falhas >= MAX_FALHAS ? null : LocalDateTime.now().plusSeconds(30));
            coleta.setMensagem(falhas >= MAX_FALHAS
                    ? "Coleta pausada apos 3 falhas. Clique em Retomar para tentar novamente."
                    : "A API do GCD falhou. Uma nova tentativa sera feita.");
        }
        return resposta(coleta);
    }

    public ColetaGuiaRespostaDTO buscar(UUID id) {
        Usuario usuario = usuarioAutenticado.obterUsuario();
        return resposta(repository.buscarPorUsuario(id, usuario.getId(), FonteColetaCatalogo.GCD)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Coleta do GCD nao encontrada.")));
    }

    @Transactional
    public ColetaGuiaRespostaDTO retomar(UUID id) {
        ColetaGuia coleta = obterComLock(id);
        if (coleta.getStatus() != StatusColetaGuia.CONCLUIDA) {
            coleta.setStatus(StatusColetaGuia.PRONTA);
            coleta.setFalhasConsecutivas(0);
            coleta.setProximaExecucao(null);
            coleta.setMensagem("Coleta do GCD retomada.");
        }
        return resposta(coleta);
    }

    @Transactional
    public ColetaGuiaRespostaDTO pausar(UUID id) {
        ColetaGuia coleta = obterComLock(id);
        if (coleta.getStatus() != StatusColetaGuia.CONCLUIDA) {
            coleta.setStatus(StatusColetaGuia.PAUSADA);
            coleta.setProximaExecucao(null);
            coleta.setMensagem("Coleta pausada pelo usuario. O progresso foi preservado.");
        }
        return resposta(coleta);
    }

    @Transactional
    public ColetaGuiaRespostaDTO finalizarParcial(UUID id) {
        ColetaGuia coleta = obterComLock(id);
        List<String> urls = ler(coleta.getUrlsJson(), STRINGS);
        List<EdicaoImportacaoDTO> edicoes = new ArrayList<>(ler(coleta.getEdicoesJson(), EDICOES));
        if (edicoes.isEmpty()) {
            throw new RegraNegocioException("Colete ao menos uma edicao antes de gerar o JSON parcial.");
        }
        List<String> avisos = new ArrayList<>(ler(coleta.getAvisosJson(), STRINGS));
        GeracaoRascunhoGcdDTO pedido = ler(coleta.getPedidoJson(), GeracaoRascunhoGcdDTO.class);
        String editora = avisos.isEmpty() ? pedido.editora() : avisos.get(0).replace("Editora selecionada: ", "");
        List<String> urlsProcessadas = urls.subList(0, Math.min(edicoes.size(), urls.size()));
        avisos.add("JSON parcial gerado com " + edicoes.size() + " edicoes. A proxima coleta pode iniciar na edicao "
                + ((pedido.inicio() == null ? 1 : pedido.inicio()) + edicoes.size()) + ".");
        concluir(coleta, pedido, editora, urlsProcessadas, edicoes, avisos);
        return resposta(coleta);
    }

    private ColetaGuia obterComLock(UUID id) {
        Usuario usuario = usuarioAutenticado.obterUsuario();
        return repository.buscarParaProcessamento(id, usuario.getId(), FonteColetaCatalogo.GCD)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Coleta do GCD nao encontrada."));
    }

    private void concluir(ColetaGuia coleta, GeracaoRascunhoGcdDTO pedido, String editora,
            List<String> urls, List<EdicaoImportacaoDTO> edicoes, List<String> avisos) {
        ImportacaoCatalogoDTO resultado = gcd.montarResultado(pedido, editora, urls, edicoes, avisos);
        coleta.setResultadoJson(json(resultado));
        coleta.setStatus(StatusColetaGuia.CONCLUIDA);
        coleta.setMensagem("JSON do GCD gerado. Revise os dados antes de importar.");
    }

    private ColetaGuiaRespostaDTO resposta(ColetaGuia coleta) {
        LocalDateTime agora = LocalDateTime.now();
        long segundos = coleta.getProximaExecucao() == null ? 0
                : Math.max(0, Duration.between(agora, coleta.getProximaExecucao()).toSeconds());
        return new ColetaGuiaRespostaDTO(coleta.getId(), coleta.getStatus().name(), coleta.getTotalPaginas(),
                coleta.getPaginasProcessadas(), coleta.getProximaExecucao(), segundos, coleta.getMensagem(),
                ler(coleta.getAvisosJson(), STRINGS), coleta.getResultadoJson() == null ? null
                        : ler(coleta.getResultadoJson(), ImportacaoCatalogoDTO.class));
    }

    private String json(Object valor) {
        try { return mapper.writeValueAsString(valor); }
        catch (JsonProcessingException e) { throw new RegraNegocioException("Nao foi possivel salvar a coleta do GCD."); }
    }

    private <T> T ler(String valor, Class<T> tipo) {
        try { return mapper.readValue(valor, tipo); }
        catch (JsonProcessingException e) { throw new RegraNegocioException("A coleta salva do GCD esta invalida."); }
    }

    private <T> T ler(String valor, TypeReference<T> tipo) {
        try { return mapper.readValue(valor, tipo); }
        catch (JsonProcessingException e) { throw new RegraNegocioException("A coleta salva do GCD esta invalida."); }
    }
}
