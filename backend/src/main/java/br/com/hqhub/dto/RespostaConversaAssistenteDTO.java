package br.com.hqhub.dto;

public record RespostaConversaAssistenteDTO(
        MensagemAssistenteRespostaDTO mensagemUsuario,
        MensagemAssistenteRespostaDTO mensagemAssistente) {
}
