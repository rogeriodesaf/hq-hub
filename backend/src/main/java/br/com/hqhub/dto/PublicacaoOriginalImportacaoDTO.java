package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;

public record PublicacaoOriginalImportacaoDTO(
        @NotBlank(message = "Série original é obrigatória.")
        String serieOriginal,

        @NotBlank(message = "Número original é obrigatório.")
        String numeroOriginal,

        Integer anoOriginal,
        String texto,
        String urlEdicaoOriginal,
        String urlCapaOriginal) {
}
