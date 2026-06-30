package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CapaUrlDTO(
        @NotBlank(message = "URL da imagem é obrigatória.")
        @Size(max = 1000, message = "URL da imagem deve ter no máximo 1000 caracteres.")
        String urlImagem) {
}
