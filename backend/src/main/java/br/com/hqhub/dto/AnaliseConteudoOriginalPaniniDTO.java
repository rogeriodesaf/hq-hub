package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record AnaliseConteudoOriginalPaniniDTO(
        @NotBlank @Size(max = 1000) String urlPanini) {
}
