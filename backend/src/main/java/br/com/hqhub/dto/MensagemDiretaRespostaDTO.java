package br.com.hqhub.dto;

import java.time.LocalDateTime;

public record MensagemDiretaRespostaDTO(
        Long id,
        UsuarioRespostaDTO remetente,
        UsuarioRespostaDTO destinatario,
        String texto,
        boolean lida,
        LocalDateTime dataCriacao) {
}
