package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;

public record PerguntaAssistenteDTO(
        @NotBlank(message = "A pergunta é obrigatória.")
        String pergunta) {
}
