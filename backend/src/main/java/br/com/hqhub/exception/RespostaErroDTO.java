package br.com.hqhub.exception;

import java.time.LocalDateTime;

public record RespostaErroDTO(
        String mensagem,
        int status,
        LocalDateTime dataHora) {
}
