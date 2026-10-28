package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CadastroEdicaoOriginalPaniniDTO(
        @NotBlank @Size(max = 1000) String urlPanini,
        @NotBlank @Size(max = 255) String serie,
        Integer anoSerie,
        @NotBlank @Size(max = 50) String numero) {
}
