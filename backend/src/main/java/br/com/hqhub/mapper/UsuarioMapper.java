package br.com.hqhub.mapper;

import br.com.hqhub.dto.CadastroUsuarioDTO;
import br.com.hqhub.dto.UsuarioRespostaDTO;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.service.UrlPublicaService;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class UsuarioMapper {

    private final UrlPublicaService urlPublicaService;

    public UsuarioMapper(UrlPublicaService urlPublicaService) {
        this.urlPublicaService = urlPublicaService;
    }

    public Usuario paraEntidade(CadastroUsuarioDTO dto) {
        Usuario usuario = new Usuario();
        usuario.setNome(dto.nome());
        usuario.setEmail(dto.email());
        usuario.setSenha(dto.senha());
        return usuario;
    }

    public UsuarioRespostaDTO paraResposta(Usuario usuario) {
        return new UsuarioRespostaDTO(
                usuario.getId(),
                usuario.getNome(),
                usuario.getEmail(),
                usuario.getPerfil().name(),
                usuario.getBio(),
                urlPublicaService.normalizarApiUrl(usuario.getFotoPerfilUrl()),
                urlPublicaService.normalizarApiUrl(usuario.getFotoPerfilThumbnailUrl()),
                usuario.getDataCriacao(),
                usuario.getDataAtualizacao());
    }
}
