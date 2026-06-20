package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record AtualizacaoPerfilUsuarioDTO(
        @NotBlank(message = "Nome e obrigatorio.")
        @Size(max = 255, message = "Nome deve ter no maximo 255 caracteres.")
        String nome,

        @Size(max = 500, message = "Bio deve ter no maximo 500 caracteres.")
        String bio) {
}
