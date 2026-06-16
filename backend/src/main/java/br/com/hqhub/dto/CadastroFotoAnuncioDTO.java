package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;

public record CadastroFotoAnuncioDTO(
        @NotBlank(message = "A URL da imagem é obrigatória.")
        String urlImagem,

        Boolean principal) {
}
