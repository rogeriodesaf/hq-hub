package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CadastroSolicitacaoImportacaoDTO(
        @NotBlank(message = "Fonte externa é obrigatória.")
        @Size(max = 100, message = "Fonte externa deve ter no máximo 100 caracteres.")
        String fonteExterna,

        @NotBlank(message = "Termo de importação é obrigatório.")
        @Size(max = 255, message = "Termo de importação deve ter no máximo 255 caracteres.")
        String termo,

        @Size(max = 1000, message = "URL de origem deve ter no máximo 1000 caracteres.")
        String urlOrigem) {
}
