package br.com.hqhub.service;

import br.com.hqhub.dto.AutenticacaoUsuarioDTO;
import br.com.hqhub.dto.UsuarioAutenticadoDTO;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.repository.UsuarioRepository;
import io.quarkus.elytron.security.common.BcryptUtil;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class AutenticacaoService {

    private final UsuarioRepository usuarioRepository;
    private final TokenService tokenService;

    public AutenticacaoService(UsuarioRepository usuarioRepository, TokenService tokenService) {
        this.usuarioRepository = usuarioRepository;
        this.tokenService = tokenService;
    }

    public UsuarioAutenticadoDTO autenticar(AutenticacaoUsuarioDTO dto) {
        Usuario usuario = usuarioRepository.buscarPorEmail(dto.email())
                .orElseThrow(() -> new RegraNegocioException("E-mail ou senha inválidos."));

        if (!BcryptUtil.matches(dto.senha(), usuario.getSenha())) {
            throw new RegraNegocioException("E-mail ou senha inválidos.");
        }

        return new UsuarioAutenticadoDTO(
                usuario.getId(),
                usuario.getNome(),
                usuario.getEmail(),
                tokenService.gerarToken(usuario),
                "Bearer",
                tokenService.obterTempoExpiracaoEmSegundos(),
                "Login realizado com sucesso.");
    }
}
