package br.com.hqhub.service;

import java.time.LocalDateTime;
import java.util.List;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import br.com.hqhub.dto.CadastroSolicitacaoImportacaoDTO;
import br.com.hqhub.dto.RespostaBuscaExternaDTO;
import br.com.hqhub.dto.SolicitacaoImportacaoRespostaDTO;
import br.com.hqhub.entity.SolicitacaoImportacao;
import br.com.hqhub.entity.StatusSolicitacaoImportacao;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.SolicitacaoImportacaoMapper;
import br.com.hqhub.repository.SolicitacaoImportacaoRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class SolicitacaoImportacaoService {

    private final SolicitacaoImportacaoRepository solicitacaoImportacaoRepository;
    private final SolicitacaoImportacaoMapper solicitacaoImportacaoMapper;
    private final UsuarioAutenticadoService usuarioAutenticadoService;
    private final IntegracaoExternaService integracaoExternaService;
    private final ObjectMapper objectMapper;

    public SolicitacaoImportacaoService(
            SolicitacaoImportacaoRepository solicitacaoImportacaoRepository,
            SolicitacaoImportacaoMapper solicitacaoImportacaoMapper,
            UsuarioAutenticadoService usuarioAutenticadoService,
            IntegracaoExternaService integracaoExternaService,
            ObjectMapper objectMapper) {
        this.solicitacaoImportacaoRepository = solicitacaoImportacaoRepository;
        this.solicitacaoImportacaoMapper = solicitacaoImportacaoMapper;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
        this.integracaoExternaService = integracaoExternaService;
        this.objectMapper = objectMapper;
    }

    @Transactional
    public SolicitacaoImportacaoRespostaDTO cadastrar(CadastroSolicitacaoImportacaoDTO dto) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        SolicitacaoImportacao solicitacao = solicitacaoImportacaoMapper.paraEntidade(dto, usuario);
        solicitacaoImportacaoRepository.persist(solicitacao);
        return solicitacaoImportacaoMapper.paraResposta(solicitacao);
    }

    public SolicitacaoImportacaoRespostaDTO buscarPorId(Long id) {
        return solicitacaoImportacaoMapper.paraResposta(buscarSolicitacaoDoUsuario(id));
    }

    public List<SolicitacaoImportacaoRespostaDTO> listarTodos() {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        return solicitacaoImportacaoRepository.list("usuario.id", usuario.getId())
                .stream()
                .map(solicitacaoImportacaoMapper::paraResposta)
                .toList();
    }

    @Transactional
    public SolicitacaoImportacaoRespostaDTO processar(Long id) {
        SolicitacaoImportacao solicitacao = buscarSolicitacaoDoUsuario(id);
        solicitacao.setStatus(StatusSolicitacaoImportacao.PROCESSANDO);
        solicitacao.setMensagem("Processando consulta na fonte externa.");

        try {
            RespostaBuscaExternaDTO resultado = integracaoExternaService.buscar(
                    solicitacao.getFonteExterna(),
                    solicitacao.getTermo());

            solicitacao.setResultadoJson(objectMapper.writeValueAsString(resultado));
            if (!resultado.resultados().isEmpty()) {
                solicitacao.setUrlOrigem(resultado.resultados().get(0).urlOrigem());
            }
            solicitacao.setStatus(StatusSolicitacaoImportacao.CONCLUIDA);
            solicitacao.setMensagem("Importação consultada com sucesso. Resultados encontrados: "
                    + resultado.resultados().size() + ".");
            solicitacao.setDataProcessamento(LocalDateTime.now());

            return solicitacaoImportacaoMapper.paraResposta(solicitacao);
        } catch (JsonProcessingException e) {
            solicitacao.setStatus(StatusSolicitacaoImportacao.FALHOU);
            solicitacao.setMensagem("Não foi possível salvar o resultado da importação.");
            solicitacao.setDataProcessamento(LocalDateTime.now());
            throw new RegraNegocioException("Não foi possível salvar o resultado da importação.");
        } catch (RuntimeException e) {
            solicitacao.setStatus(StatusSolicitacaoImportacao.FALHOU);
            solicitacao.setMensagem(e.getMessage());
            solicitacao.setDataProcessamento(LocalDateTime.now());
            throw e;
        }
    }

    private SolicitacaoImportacao buscarSolicitacaoDoUsuario(Long id) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        return solicitacaoImportacaoRepository
                .find("id = ?1 and usuario.id = ?2", id, usuario.getId())
                .firstResultOptional()
                .orElseThrow(() -> new RecursoNaoEncontradoException("Solicitação de importação não encontrada."));
    }
}
