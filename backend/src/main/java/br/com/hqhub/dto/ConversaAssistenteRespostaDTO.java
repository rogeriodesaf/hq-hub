package br.com.hqhub.dto;

import java.time.LocalDateTime;

public record ConversaAssistenteRespostaDTO(
        Long id,
        String titulo,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
