package br.com.hqhub.service;

import java.util.List;

import br.com.hqhub.dto.CadastroUsuarioDTO;
import br.com.hqhub.dto.UsuarioRespostaDTO;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.UsuarioMapper;
import br.com.hqhub.repository.UsuarioRepository;
import io.quarkus.elytron.security.common.BcryptUtil;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final UsuarioMapper usuarioMapper;

    public UsuarioService(UsuarioRepository usuarioRepository, UsuarioMapper usuarioMapper) {
        this.usuarioRepository = usuarioRepository;
        this.usuarioMapper = usuarioMapper;
    }

    @Transactional
    public UsuarioRespostaDTO cadastrar(CadastroUsuarioDTO dto) {
        if (usuarioRepository.existePorEmail(dto.email())) {
            throw new RegraNegocioException("Já existe um usuário cadastrado com este e-mail.");
        }

        Usuario usuario = usuarioMapper.paraEntidade(dto);
        usuario.setSenha(BcryptUtil.bcryptHash(dto.senha()));
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
}
