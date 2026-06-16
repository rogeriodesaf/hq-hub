package br.com.hqhub.dto;

import br.com.hqhub.entity.PapelCriador;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CadastroCreditoEdicaoDTO(
        @NotNull(message = "Edição é obrigatória.")
        Long edicaoId,

        @NotNull(message = "Criador é obrigatório.")
        Long criadorId,

        @NotNull(message = "Papel do criador é obrigatório.")
        PapelCriador papel,

        @Size(max = 500, message = "Observações devem ter no máximo 500 caracteres.")
        String observacoes) {
}
