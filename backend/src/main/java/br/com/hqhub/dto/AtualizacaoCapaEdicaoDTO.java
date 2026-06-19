package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record AtualizacaoCapaEdicaoDTO(
        @NotBlank(message = "URL da capa é obrigatória.")
        @Size(max = 1000, message = "URL da capa deve ter no máximo 1000 caracteres.")
        String urlCapa) {
}
