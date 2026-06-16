package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CadastroDenunciaAnuncioDTO(
        @NotNull(message = "O anúncio é obrigatório.")
        Long anuncioId,

        @NotBlank(message = "O motivo é obrigatório.")
        String motivo,

        @Size(max = 1000, message = "A descrição deve ter no máximo 1000 caracteres.")
        String descricao) {
}
