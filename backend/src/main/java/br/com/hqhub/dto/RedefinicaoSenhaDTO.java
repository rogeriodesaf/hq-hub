package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RedefinicaoSenhaDTO(
        @NotBlank(message = "Token é obrigatório.")
        String token,

        @NotBlank(message = "Nova senha é obrigatória.")
        @Size(min = 6, message = "A senha deve ter no mínimo 6 caracteres.")
        String novaSenha) {
}
