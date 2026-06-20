package br.com.hqhub.dto;

import java.time.LocalDateTime;

public record ConversaDiretaRespostaDTO(
        UsuarioRespostaDTO usuario,
        MensagemDiretaRespostaDTO ultimaMensagem,
        long naoLidas,
        LocalDateTime dataUltimaMensagem) {
}
