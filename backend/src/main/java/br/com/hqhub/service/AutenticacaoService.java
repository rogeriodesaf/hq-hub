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
    private final UrlPublicaService urlPublicaService;

    public AutenticacaoService(UsuarioRepository usuarioRepository, TokenService tokenService, UrlPublicaService urlPublicaService) {
        this.usuarioRepository = usuarioRepository;
        this.tokenService = tokenService;
        this.urlPublicaService = urlPublicaService;
    }

    public UsuarioAutenticadoDTO autenticar(AutenticacaoUsuarioDTO dto) {
        Usuario usuario = usuarioRepository.buscarPorEmail(dto.email())
                .orElseThrow(() -> new RegraNegocioException("E-mail ou senha invalidos."));

        if (!senhaConfere(dto.senha(), usuario.getSenha())) {
            throw new RegraNegocioException("E-mail ou senha invalidos.");
        }

        return new UsuarioAutenticadoDTO(
                usuario.getId(),
                usuario.getNome(),
                usuario.getEmail(),
                usuario.getPerfil().name(),
                usuario.getBio(),
                urlPublicaService.normalizarApiUrl(usuario.getFotoPerfilUrl()),
                urlPublicaService.normalizarApiUrl(usuario.getFotoPerfilThumbnailUrl()),
                tokenService.gerarToken(usuario),
                "Bearer",
                tokenService.obterTempoExpiracaoEmSegundos(),
                "Login realizado com sucesso.");
    }

    private boolean senhaConfere(String senhaInformada, String senhaSalva) {
        if (senhaSalva == null || senhaInformada == null) {
            return false;
        }

        if (senhaSalva.startsWith("$2")) {
            return BcryptUtil.matches(senhaInformada, senhaSalva);
        }

        return senhaSalva.equals(senhaInformada);
    }
}
