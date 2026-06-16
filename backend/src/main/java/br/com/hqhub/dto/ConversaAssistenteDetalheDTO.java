package br.com.hqhub.dto;

import java.util.List;

public record ConversaAssistenteDetalheDTO(
        ConversaAssistenteRespostaDTO conversa,
        List<MensagemAssistenteRespostaDTO> mensagens) {
}
