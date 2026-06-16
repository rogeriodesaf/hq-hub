package br.com.hqhub.dto;

import br.com.hqhub.entity.StatusColecaoSerie;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CadastroColecaoSerieDTO(
        @NotNull(message = "Série é obrigatória.")
        Long serieId,

        @NotNull(message = "Status da coleção é obrigatório.")
        StatusColecaoSerie status,

        @Min(value = 1, message = "Prioridade deve ser maior ou igual a 1.")
        @Max(value = 5, message = "Prioridade deve ser menor ou igual a 5.")
        Integer prioridade,

        @Size(max = 1000, message = "Observações devem ter no máximo 1000 caracteres.")
        String observacoes) {
}
