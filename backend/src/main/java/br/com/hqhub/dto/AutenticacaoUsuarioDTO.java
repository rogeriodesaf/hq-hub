package br.com.hqhub.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record AutenticacaoUsuarioDTO(
        @NotBlank(message = "E-mail é obrigatório.")
        @Email(message = "E-mail deve ser válido.")
        String email,

        @NotBlank(message = "Senha é obrigatória.")
        String senha) {
}
