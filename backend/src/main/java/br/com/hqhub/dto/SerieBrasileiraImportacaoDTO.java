package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;

public record SerieBrasileiraImportacaoDTO(
        @NotBlank(message = "Título da série é obrigatório.")
        String titulo,

        String fase,

        @NotBlank(message = "Editora da série é obrigatória.")
        String editora,

        Integer volume) {
}
