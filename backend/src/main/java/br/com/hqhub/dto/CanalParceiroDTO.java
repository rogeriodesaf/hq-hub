package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CanalParceiroDTO(
        @Size(max = 200, message = "Nome do canal deve ter no máximo 200 caracteres.")
        String name,

        @NotBlank(message = "Link do canal parceiro é obrigatório.")
        @Size(max = 1000, message = "Link do canal deve ter no máximo 1000 caracteres.")
        String url,

        @Size(max = 1000, message = "Imagem do canal deve ter no máximo 1000 caracteres.")
        String thumbnail) {
}
