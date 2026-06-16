package br.com.hqhub.service;

import org.eclipse.microprofile.jwt.JsonWebToken;

import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.repository.UsuarioRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class UsuarioAutenticadoService {

    private final JsonWebToken token;
    private final UsuarioRepository usuarioRepository;

    public UsuarioAutenticadoService(JsonWebToken token, UsuarioRepository usuarioRepository) {
        this.token = token;
        this.usuarioRepository = usuarioRepository;
    }

    public Usuario obterUsuario() {
        Long usuarioId = Long.valueOf(token.getSubject());

        return usuarioRepository.findByIdOptional(usuarioId)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Usuário autenticado não encontrado."));
    }
}
