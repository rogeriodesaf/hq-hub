package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CadastroMensagemDiretaDTO(
        @NotNull(message = "Destinatario e obrigatorio.")
        Long destinatarioId,

        @NotBlank(message = "Escreva uma mensagem antes de enviar.")
        @Size(max = 2000, message = "A mensagem deve ter no maximo 2000 caracteres.")
        String texto) {
}
