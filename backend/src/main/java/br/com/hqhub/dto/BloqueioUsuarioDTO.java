package br.com.hqhub.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record BloqueioUsuarioDTO(
        @NotNull(message = "O usuário bloqueado é obrigatório.")
        Long usuarioBloqueadoId,

        @Size(max = 500, message = "O motivo deve ter no máximo 500 caracteres.")
        String motivo) {
}
