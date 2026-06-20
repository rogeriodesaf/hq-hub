package br.com.hqhub.mapper;

import br.com.hqhub.dto.MensagemDiretaRespostaDTO;
import br.com.hqhub.entity.MensagemDireta;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class MensagemDiretaMapper {

    private final UsuarioMapper usuarioMapper;

    public MensagemDiretaMapper(UsuarioMapper usuarioMapper) {
        this.usuarioMapper = usuarioMapper;
    }

    public MensagemDiretaRespostaDTO paraResposta(MensagemDireta mensagem) {
        return new MensagemDiretaRespostaDTO(
                mensagem.getId(),
                usuarioMapper.paraResposta(mensagem.getRemetente()),
                usuarioMapper.paraResposta(mensagem.getDestinatario()),
                mensagem.getTexto(),
                mensagem.isLida(),
                mensagem.getDataCriacao());
    }
}
