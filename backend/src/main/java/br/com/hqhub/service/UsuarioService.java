package br.com.hqhub.service;

import java.util.List;

import br.com.hqhub.dto.AtualizacaoPerfilUsuarioDTO;
import br.com.hqhub.dto.CadastroColaboradorDTO;
import br.com.hqhub.dto.CadastroUsuarioDTO;
import br.com.hqhub.dto.ImagemFeedDTO;
import br.com.hqhub.dto.UsuarioRespostaDTO;
import br.com.hqhub.entity.PerfilUsuario;
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
    private final FeedMidiaService feedMidiaService;

    public UsuarioService(
            UsuarioRepository usuarioRepository,
            UsuarioMapper usuarioMapper,
            UsuarioAutenticadoService usuarioAutenticadoService,
            FeedMidiaService feedMidiaService) {
        this.usuarioRepository = usuarioRepository;
        this.usuarioMapper = usuarioMapper;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
        this.feedMidiaService = feedMidiaService;
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

    @Transactional
    public UsuarioRespostaDTO cadastrarColaborador(CadastroColaboradorDTO dto) {
        String email = dto.email().trim().toLowerCase();
        Usuario usuarioExistente = usuarioRepository.buscarPorEmail(email).orElse(null);
        if (usuarioExistente != null) {
            usuarioExistente.setNome(dto.nome().trim());
            if (usuarioExistente.getPerfil() == PerfilUsuario.USUARIO) {
                usuarioExistente.setPerfil(PerfilUsuario.COLABORADOR);
            }
            return usuarioMapper.paraResposta(usuarioExistente);
        }

        if (dto.senha() == null || dto.senha().length() < 6) {
            throw new RegraNegocioException("Informe uma senha provisoria com pelo menos 6 caracteres para novo usuario.");
        }

        Usuario usuario = usuarioMapper.paraEntidade(new CadastroUsuarioDTO(dto.nome().trim(), email, dto.senha()));
        usuario.setPerfil(PerfilUsuario.COLABORADOR);
        usuarioRepository.persist(usuario);

        return usuarioMapper.paraResposta(usuario);
    }

    public UsuarioRespostaDTO buscarPorId(Long id) {
        Usuario usuario = usuarioRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Usuário não encontrado."));

        return usuarioMapper.paraResposta(usuario);
    }

    public List<UsuarioRespostaDTO> listarTodos(String busca) {
        return usuarioRepository.buscar(busca)
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
        String fotoAnterior = usuario.getFotoPerfilUrl();
        usuario.setFotoPerfilUrl(imagem.urlImagem());
        usuario.setFotoPerfilThumbnailUrl(imagem.urlThumbnail());

        if (fotoAnterior != null && !fotoAnterior.isBlank() && !fotoAnterior.equals(imagem.urlImagem())) {
            feedMidiaService.excluirImagemCloudinaryPorUrl(fotoAnterior);
        }

        return usuarioMapper.paraResposta(usuario);
    }

    private String textoOuNull(String valor) {
        if (valor == null || valor.isBlank()) {
            return null;
        }
        return valor.trim();
    }
}
