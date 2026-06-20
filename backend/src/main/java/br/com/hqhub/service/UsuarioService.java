package br.com.hqhub.service;

import java.util.List;

import br.com.hqhub.dto.AtualizacaoPerfilUsuarioDTO;
import br.com.hqhub.dto.CadastroUsuarioDTO;
import br.com.hqhub.dto.ImagemFeedDTO;
import br.com.hqhub.dto.UsuarioRespostaDTO;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.UsuarioMapper;
import br.com.hqhub.repository.UsuarioRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final UsuarioMapper usuarioMapper;
    private final UsuarioAutenticadoService usuarioAutenticadoService;

    public UsuarioService(
            UsuarioRepository usuarioRepository,
            UsuarioMapper usuarioMapper,
            UsuarioAutenticadoService usuarioAutenticadoService) {
        this.usuarioRepository = usuarioRepository;
        this.usuarioMapper = usuarioMapper;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
    }

    @Transactional
    public UsuarioRespostaDTO cadastrar(CadastroUsuarioDTO dto) {
        if (usuarioRepository.existePorEmail(dto.email())) {
            throw new RegraNegocioException("Já existe um usuário cadastrado com este e-mail.");
        }

        Usuario usuario = usuarioMapper.paraEntidade(dto);
        // TODO: implementar criptografia de senha posteriormente.
        usuarioRepository.persist(usuario);

        return usuarioMapper.paraResposta(usuario);
    }

    public UsuarioRespostaDTO buscarPorId(Long id) {
        Usuario usuario = usuarioRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Usuário não encontrado."));

        return usuarioMapper.paraResposta(usuario);
    }

    public List<UsuarioRespostaDTO> listarTodos() {
        return usuarioRepository.listAll()
                .stream()
                .map(usuarioMapper::paraResposta)
                .toList();
    }

    public UsuarioRespostaDTO obterMeuPerfil() {
        return usuarioMapper.paraResposta(usuarioAutenticadoService.obterUsuario());
    }

    @Transactional
    public UsuarioRespostaDTO atualizarMeuPerfil(AtualizacaoPerfilUsuarioDTO dto) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        usuario.setNome(dto.nome().trim());
        usuario.setBio(textoOuNull(dto.bio()));
        return usuarioMapper.paraResposta(usuario);
    }

    @Transactional
    public UsuarioRespostaDTO atualizarFotoPerfil(ImagemFeedDTO imagem) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        usuario.setFotoPerfilUrl(imagem.urlImagem());
        usuario.setFotoPerfilThumbnailUrl(imagem.urlThumbnail());
        return usuarioMapper.paraResposta(usuario);
    }

    private String textoOuNull(String valor) {
        if (valor == null || valor.isBlank()) {
            return null;
        }
        return valor.trim();
    }
}
