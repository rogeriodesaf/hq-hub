package br.com.hqhub.mapper;

import br.com.hqhub.dto.CadastroDenunciaAnuncioDTO;
import br.com.hqhub.dto.CadastroDenunciaUsuarioDTO;
import br.com.hqhub.dto.DenunciaAnuncioRespostaDTO;
import br.com.hqhub.dto.DenunciaUsuarioRespostaDTO;
import br.com.hqhub.entity.Anuncio;
import br.com.hqhub.entity.DenunciaAnuncio;
import br.com.hqhub.entity.DenunciaUsuario;
import br.com.hqhub.entity.StatusDenuncia;
import br.com.hqhub.entity.Usuario;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class DenunciaMapper {

    private final AnuncioMapper anuncioMapper;
    private final UsuarioMapper usuarioMapper;

    public DenunciaMapper(AnuncioMapper anuncioMapper, UsuarioMapper usuarioMapper) {
        this.anuncioMapper = anuncioMapper;
        this.usuarioMapper = usuarioMapper;
    }

    public DenunciaAnuncio paraEntidade(CadastroDenunciaAnuncioDTO dto, Usuario denunciante, Anuncio anuncio) {
        DenunciaAnuncio denuncia = new DenunciaAnuncio();
        denuncia.setDenunciante(denunciante);
        denuncia.setAnuncio(anuncio);
        denuncia.setMotivo(dto.motivo());
        denuncia.setDescricao(dto.descricao());
        denuncia.setStatus(StatusDenuncia.PENDENTE);
        return denuncia;
    }

    public DenunciaUsuario paraEntidade(CadastroDenunciaUsuarioDTO dto, Usuario denunciante, Usuario usuarioDenunciado) {
        DenunciaUsuario denuncia = new DenunciaUsuario();
        denuncia.setDenunciante(denunciante);
        denuncia.setUsuarioDenunciado(usuarioDenunciado);
        denuncia.setMotivo(dto.motivo());
        denuncia.setDescricao(dto.descricao());
        denuncia.setStatus(StatusDenuncia.PENDENTE);
        return denuncia;
    }

    public DenunciaAnuncioRespostaDTO paraResposta(DenunciaAnuncio denuncia) {
        return new DenunciaAnuncioRespostaDTO(
                denuncia.getId(),
                anuncioMapper.paraResposta(denuncia.getAnuncio()),
                denuncia.getMotivo(),
                denuncia.getDescricao(),
                denuncia.getStatus(),
                denuncia.getDataCriacao(),
                denuncia.getDataAtualizacao());
    }

    public DenunciaUsuarioRespostaDTO paraResposta(DenunciaUsuario denuncia) {
        return new DenunciaUsuarioRespostaDTO(
                denuncia.getId(),
                usuarioMapper.paraResposta(denuncia.getUsuarioDenunciado()),
                denuncia.getMotivo(),
                denuncia.getDescricao(),
                denuncia.getStatus(),
                denuncia.getDataCriacao(),
                denuncia.getDataAtualizacao());
    }
}
