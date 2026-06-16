package br.com.hqhub.mapper;

import br.com.hqhub.dto.AmizadeRespostaDTO;
import br.com.hqhub.dto.BloqueioUsuarioRespostaDTO;
import br.com.hqhub.entity.Amizade;
import br.com.hqhub.entity.BloqueioUsuario;
import br.com.hqhub.entity.StatusAmizade;
import br.com.hqhub.entity.Usuario;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class AmizadeMapper {

    private final UsuarioMapper usuarioMapper;

    public AmizadeMapper(UsuarioMapper usuarioMapper) {
        this.usuarioMapper = usuarioMapper;
    }

    public Amizade paraEntidade(Usuario solicitante, Usuario solicitado) {
        Amizade amizade = new Amizade();
        amizade.setSolicitante(solicitante);
        amizade.setSolicitado(solicitado);
        amizade.setStatus(StatusAmizade.PENDENTE);
        return amizade;
    }

    public BloqueioUsuario paraBloqueio(Usuario usuario, Usuario usuarioBloqueado, String motivo) {
        BloqueioUsuario bloqueio = new BloqueioUsuario();
        bloqueio.setUsuario(usuario);
        bloqueio.setUsuarioBloqueado(usuarioBloqueado);
        bloqueio.setMotivo(motivo);
        return bloqueio;
    }

    public AmizadeRespostaDTO paraResposta(Amizade amizade) {
        return new AmizadeRespostaDTO(
                amizade.getId(),
                usuarioMapper.paraResposta(amizade.getSolicitante()),
                usuarioMapper.paraResposta(amizade.getSolicitado()),
                amizade.getStatus(),
                amizade.getDataSolicitacao(),
                amizade.getDataResposta());
    }

    public BloqueioUsuarioRespostaDTO paraResposta(BloqueioUsuario bloqueio) {
        return new BloqueioUsuarioRespostaDTO(
                bloqueio.getId(),
                usuarioMapper.paraResposta(bloqueio.getUsuarioBloqueado()),
                bloqueio.getMotivo(),
                bloqueio.getDataBloqueio());
    }
}
