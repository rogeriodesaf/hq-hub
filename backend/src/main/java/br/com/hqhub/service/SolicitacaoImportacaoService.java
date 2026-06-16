package br.com.hqhub.service;

import java.util.List;

import br.com.hqhub.dto.CadastroSolicitacaoImportacaoDTO;
import br.com.hqhub.dto.SolicitacaoImportacaoRespostaDTO;
import br.com.hqhub.entity.SolicitacaoImportacao;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.mapper.SolicitacaoImportacaoMapper;
import br.com.hqhub.repository.SolicitacaoImportacaoRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class SolicitacaoImportacaoService {

    private final SolicitacaoImportacaoRepository solicitacaoImportacaoRepository;
    private final SolicitacaoImportacaoMapper solicitacaoImportacaoMapper;
    private final UsuarioAutenticadoService usuarioAutenticadoService;

    public SolicitacaoImportacaoService(
            SolicitacaoImportacaoRepository solicitacaoImportacaoRepository,
            SolicitacaoImportacaoMapper solicitacaoImportacaoMapper,
            UsuarioAutenticadoService usuarioAutenticadoService) {
        this.solicitacaoImportacaoRepository = solicitacaoImportacaoRepository;
        this.solicitacaoImportacaoMapper = solicitacaoImportacaoMapper;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
    }

    @Transactional
    public SolicitacaoImportacaoRespostaDTO cadastrar(CadastroSolicitacaoImportacaoDTO dto) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        SolicitacaoImportacao solicitacao = solicitacaoImportacaoMapper.paraEntidade(dto, usuario);
        solicitacaoImportacaoRepository.persist(solicitacao);
        return solicitacaoImportacaoMapper.paraResposta(solicitacao);
    }

    public SolicitacaoImportacaoRespostaDTO buscarPorId(Long id) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        SolicitacaoImportacao solicitacao = solicitacaoImportacaoRepository
                .find("id = ?1 and usuario.id = ?2", id, usuario.getId())
                .firstResultOptional()
                .orElseThrow(() -> new RecursoNaoEncontradoException("Solicitação de importação não encontrada."));
        return solicitacaoImportacaoMapper.paraResposta(solicitacao);
    }

    public List<SolicitacaoImportacaoRespostaDTO> listarTodos() {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        return solicitacaoImportacaoRepository.list("usuario.id", usuario.getId())
                .stream()
                .map(solicitacaoImportacaoMapper::paraResposta)
                .toList();
    }
}
