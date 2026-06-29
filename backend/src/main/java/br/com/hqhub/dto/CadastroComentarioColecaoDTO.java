package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CadastroComentarioColecaoDTO(
        @NotBlank(message = "Escreva um comentario antes de enviar.")
        @Size(max = 1000, message = "O comentario deve ter no maximo 1000 caracteres.")
        String texto) {
}
