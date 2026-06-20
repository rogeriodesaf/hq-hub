package br.com.hqhub.service;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import br.com.hqhub.dto.CadastroMensagemDiretaDTO;
import br.com.hqhub.dto.ConversaDiretaRespostaDTO;
import br.com.hqhub.dto.MensagemDiretaRespostaDTO;
import br.com.hqhub.entity.MensagemDireta;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.MensagemDiretaMapper;
import br.com.hqhub.mapper.UsuarioMapper;
import br.com.hqhub.repository.MensagemDiretaRepository;
import br.com.hqhub.repository.UsuarioRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class MensagemDiretaService {

    private final MensagemDiretaRepository mensagemDiretaRepository;
    private final UsuarioRepository usuarioRepository;
    private final UsuarioAutenticadoService usuarioAutenticadoService;
    private final AmizadeService amizadeService;
    private final MensagemDiretaMapper mensagemDiretaMapper;
    private final UsuarioMapper usuarioMapper;

    public MensagemDiretaService(
            MensagemDiretaRepository mensagemDiretaRepository,
            UsuarioRepository usuarioRepository,
            UsuarioAutenticadoService usuarioAutenticadoService,
            AmizadeService amizadeService,
            MensagemDiretaMapper mensagemDiretaMapper,
            UsuarioMapper usuarioMapper) {
        this.mensagemDiretaRepository = mensagemDiretaRepository;
        this.usuarioRepository = usuarioRepository;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
        this.amizadeService = amizadeService;
        this.mensagemDiretaMapper = mensagemDiretaMapper;
        this.usuarioMapper = usuarioMapper;
    }

    @Transactional
    public MensagemDiretaRespostaDTO enviar(CadastroMensagemDiretaDTO dto) {
        Usuario remetente = usuarioAutenticadoService.obterUsuario();
        Usuario destinatario = buscarUsuario(dto.destinatarioId());

        validarConversaPermitida(remetente.getId(), destinatario.getId());

        MensagemDireta mensagem = new MensagemDireta();
        mensagem.setRemetente(remetente);
        mensagem.setDestinatario(destinatario);
        mensagem.setTexto(dto.texto().trim());
        mensagem.setLida(false);
        mensagemDiretaRepository.persist(mensagem);

        return mensagemDiretaMapper.paraResposta(mensagem);
    }

    public List<ConversaDiretaRespostaDTO> listarConversas() {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        Map<Long, MensagemDireta> ultimasPorUsuario = new LinkedHashMap<>();

        for (MensagemDireta mensagem : mensagemDiretaRepository.listarDoUsuario(usuario.getId())) {
            Usuario outroUsuario = outroUsuario(mensagem, usuario.getId());
            ultimasPorUsuario.putIfAbsent(outroUsuario.getId(), mensagem);
        }

        return ultimasPorUsuario.values()
                .stream()
                .map(mensagem -> montarConversa(usuario.getId(), mensagem))
                .toList();
    }

    @Transactional
    public List<MensagemDiretaRespostaDTO> listarConversa(Long outroUsuarioId) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        Usuario outroUsuario = buscarUsuario(outroUsuarioId);
        validarConversaPermitida(usuario.getId(), outroUsuario.getId());

        List<MensagemDireta> mensagens = mensagemDiretaRepository.listarConversa(usuario.getId(), outroUsuario.getId());
        mensagens.stream()
                .filter(mensagem -> mensagem.getDestinatario().getId().equals(usuario.getId()))
                .filter(mensagem -> !mensagem.isLida())
                .forEach(mensagem -> mensagem.setLida(true));

        return mensagens.stream()
                .map(mensagemDiretaMapper::paraResposta)
                .toList();
    }

    public long contarNaoLidas() {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        return mensagemDiretaRepository.contarNaoLidas(usuario.getId());
    }

    private ConversaDiretaRespostaDTO montarConversa(Long usuarioId, MensagemDireta mensagem) {
        Usuario outroUsuario = outroUsuario(mensagem, usuarioId);
        long naoLidas = mensagemDiretaRepository.contarNaoLidasNaConversa(usuarioId, outroUsuario.getId());
        return new ConversaDiretaRespostaDTO(
                usuarioMapper.paraResposta(outroUsuario),
                mensagemDiretaMapper.paraResposta(mensagem),
                naoLidas,
                mensagem.getDataCriacao());
    }

    private Usuario outroUsuario(MensagemDireta mensagem, Long usuarioId) {
        if (mensagem.getRemetente().getId().equals(usuarioId)) {
            return mensagem.getDestinatario();
        }
        return mensagem.getRemetente();
    }

    private Usuario buscarUsuario(Long id) {
        return usuarioRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Usuario nao encontrado."));
    }

    private void validarConversaPermitida(Long usuarioId, Long outroUsuarioId) {
        if (usuarioId.equals(outroUsuarioId)) {
            throw new RegraNegocioException("Nao e possivel enviar direct para si mesmo.");
        }

        if (amizadeService.usuarioBloqueou(usuarioId, outroUsuarioId) || amizadeService.usuarioBloqueou(outroUsuarioId, usuarioId)) {
            throw new RegraNegocioException("Nao e possivel enviar direct para um usuario bloqueado.");
        }
    }
}
