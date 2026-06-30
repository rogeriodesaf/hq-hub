package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record ImportacaoCapaJsonDTO(
        @NotNull(message = "ID da edição é obrigatório.")
        Long idEdicao,
        @NotBlank(message = "URL da imagem é obrigatória.")
        @Size(max = 1000, message = "URL da imagem deve ter no máximo 1000 caracteres.")
        String urlImagem) {
}
