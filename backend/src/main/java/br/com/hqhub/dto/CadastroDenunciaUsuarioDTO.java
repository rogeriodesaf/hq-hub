package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CadastroDenunciaUsuarioDTO(
        @NotNull(message = "O usuário denunciado é obrigatório.")
        Long usuarioDenunciadoId,

        @NotBlank(message = "O motivo é obrigatório.")
        String motivo,

        @Size(max = 1000, message = "A descrição deve ter no máximo 1000 caracteres.")
        String descricao) {
}
