package br.com.hqhub.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record CadastroColaboradorDTO(
        @NotBlank(message = "Nome e obrigatorio.")
        String nome,

        @NotBlank(message = "E-mail e obrigatorio.")
        @Email(message = "E-mail deve ser valido.")
        String email,

        String senha) {
}
