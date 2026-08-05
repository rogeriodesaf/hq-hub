package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record AtualizacaoPostagemFeedDTO(
        @NotBlank(message = "Escreva algo para publicar.")
        @Size(max = 2000, message = "A postagem deve ter no maximo 2000 caracteres.")
        String conteudo) {
}
