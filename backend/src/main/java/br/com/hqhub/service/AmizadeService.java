package br.com.hqhub.service;

import java.time.LocalDateTime;
import java.util.List;

import br.com.hqhub.dto.AmizadeRespostaDTO;
import br.com.hqhub.dto.BloqueioUsuarioDTO;
import br.com.hqhub.dto.BloqueioUsuarioRespostaDTO;
import br.com.hqhub.dto.CadastroSolicitacaoAmizadeDTO;
import br.com.hqhub.entity.Amizade;
import br.com.hqhub.entity.BloqueioUsuario;
import br.com.hqhub.entity.StatusAmizade;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.AmizadeMapper;
import br.com.hqhub.repository.AmizadeRepository;
import br.com.hqhub.repository.BloqueioUsuarioRepository;
import br.com.hqhub.repository.UsuarioRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class AmizadeService {

    private final AmizadeRepository amizadeRepository;
    private final BloqueioUsuarioRepository bloqueioUsuarioRepository;
    private final UsuarioRepository usuarioRepository;
    private final UsuarioAutenticadoService usuarioAutenticadoService;
    private final AmizadeMapper amizadeMapper;

    public AmizadeService(
            AmizadeRepository amizadeRepository,
            BloqueioUsuarioRepository bloqueioUsuarioRepository,
            UsuarioRepository usuarioRepository,
            UsuarioAutenticadoService usuarioAutenticadoService,
            AmizadeMapper amizadeMapper) {
        this.amizadeRepository = amizadeRepository;
        this.bloqueioUsuarioRepository = bloqueioUsuarioRepository;
        this.usuarioRepository = usuarioRepository;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
        this.amizadeMapper = amizadeMapper;
    }

    @Transactional
    public AmizadeRespostaDTO enviarSolicitacao(CadastroSolicitacaoAmizadeDTO dto) {
        Usuario solicitante = usuarioAutenticadoService.obterUsuario();
        Usuario solicitado = buscarUsuarioPorId(dto.usuarioSolicitadoId());

        validarUsuariosDiferentes(solicitante.getId(), solicitado.getId(), "Não é possível enviar solicitação para si mesmo.");

        if (bloqueioUsuarioRepository.existeBloqueioEntre(solicitante.getId(), solicitado.getId())) {
            throw new RegraNegocioException("Não é possível enviar solicitação de amizade entre usuários bloqueados.");
        }

        if (amizadeRepository.existeEntreUsuarios(solicitante.getId(), solicitado.getId())) {
            throw new RegraNegocioException("Já existe uma solicitação ou amizade entre estes usuários.");
        }

        Amizade amizade = amizadeMapper.paraEntidade(solicitante, solicitado);
        amizadeRepository.persist(amizade);
        return amizadeMapper.paraResposta(amizade);
    }

    @Transactional
    public AmizadeRespostaDTO aceitar(Long id) {
        Amizade amizade = buscarSolicitacaoPendenteRecebida(id);
        amizade.setStatus(StatusAmizade.ACEITA);
        amizade.setDataResposta(LocalDateTime.now());
        return amizadeMapper.paraResposta(amizade);
    }

    @Transactional
    public AmizadeRespostaDTO recusar(Long id) {
        Amizade amizade = buscarSolicitacaoPendenteRecebida(id);
        amizade.setStatus(StatusAmizade.RECUSADA);
        amizade.setDataResposta(LocalDateTime.now());
        return amizadeMapper.paraResposta(amizade);
    }

    @Transactional
    public void removerAmigo(Long usuarioId) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        Amizade amizade = amizadeRepository.buscarEntreUsuarios(usuario.getId(), usuarioId)
                .filter(item -> item.getStatus() == StatusAmizade.ACEITA)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Amizade não encontrada."));
        amizadeRepository.delete(amizade);
    }

    @Transactional
    public BloqueioUsuarioRespostaDTO bloquear(BloqueioUsuarioDTO dto) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        Usuario usuarioBloqueado = buscarUsuarioPorId(dto.usuarioBloqueadoId());

        validarUsuariosDiferentes(usuario.getId(), usuarioBloqueado.getId(), "Não é possível bloquear a si mesmo.");

        if (bloqueioUsuarioRepository.buscarPorUsuarioEBloqueado(usuario.getId(), usuarioBloqueado.getId()).isPresent()) {
            throw new RegraNegocioException("Este usuário já está bloqueado.");
        }

        amizadeRepository.buscarEntreUsuarios(usuario.getId(), usuarioBloqueado.getId())
                .ifPresent(amizadeRepository::delete);

        BloqueioUsuario bloqueio = amizadeMapper.paraBloqueio(usuario, usuarioBloqueado, dto.motivo());
        bloqueioUsuarioRepository.persist(bloqueio);
        return amizadeMapper.paraResposta(bloqueio);
    }

    @Transactional
    public void desbloquear(Long usuarioBloqueadoId) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        BloqueioUsuario bloqueio = bloqueioUsuarioRepository.buscarPorUsuarioEBloqueado(usuario.getId(), usuarioBloqueadoId)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Bloqueio não encontrado."));
        bloqueioUsuarioRepository.delete(bloqueio);
    }

    public List<AmizadeRespostaDTO> listarAmigos() {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        return amizadeRepository.listarAmigos(usuario.getId())
                .stream()
                .map(amizadeMapper::paraResposta)
                .toList();
    }

    public List<Long> listarIdsAmigos() {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        return amizadeRepository.listarAmigos(usuario.getId())
                .stream()
                .map(amizade -> amizade.getSolicitante().getId().equals(usuario.getId())
                        ? amizade.getSolicitado().getId()
                        : amizade.getSolicitante().getId())
                .toList();
    }

    public List<AmizadeRespostaDTO> listarSolicitacoesPendentesRecebidas() {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        return amizadeRepository.listarPendentesRecebidas(usuario.getId())
                .stream()
                .map(amizadeMapper::paraResposta)
                .toList();
    }

    public long contarSolicitacoesPendentesRecebidas() {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        return amizadeRepository.listarPendentesRecebidas(usuario.getId()).size();
    }

    public List<AmizadeRespostaDTO> listarSolicitacoesPendentesEnviadas() {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        return amizadeRepository.listarPendentesEnviadas(usuario.getId())
                .stream()
                .map(amizadeMapper::paraResposta)
                .toList();
    }

    public List<BloqueioUsuarioRespostaDTO> listarBloqueios() {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        return bloqueioUsuarioRepository.listarPorUsuario(usuario.getId())
                .stream()
                .map(amizadeMapper::paraResposta)
                .toList();
    }

    public boolean saoAmigos(Long usuarioId, Long outroUsuarioId) {
        return amizadeRepository.saoAmigos(usuarioId, outroUsuarioId);
    }

    public boolean usuarioBloqueou(Long usuarioId, Long outroUsuarioId) {
        return bloqueioUsuarioRepository.buscarPorUsuarioEBloqueado(usuarioId, outroUsuarioId).isPresent();
    }

    private Amizade buscarSolicitacaoPendenteRecebida(Long id) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        return amizadeRepository.find("id = ?1 and solicitado.id = ?2 and status = ?3", id, usuario.getId(), StatusAmizade.PENDENTE)
                .firstResultOptional()
                .orElseThrow(() -> new RecursoNaoEncontradoException("Solicitação de amizade pendente não encontrada."));
    }

    private Usuario buscarUsuarioPorId(Long id) {
        return usuarioRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Usuário não encontrado."));
    }

    private void validarUsuariosDiferentes(Long usuarioId, Long outroUsuarioId, String mensagem) {
        if (usuarioId.equals(outroUsuarioId)) {
            throw new RegraNegocioException(mensagem);
        }
    }
}
