package br.com.hqhub.dto;

import java.math.BigDecimal;

import br.com.hqhub.entity.PrioridadeCompra;
import br.com.hqhub.entity.StatusCompraPlanejada;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CadastroCompraPlanejadaDTO(
        @NotNull(message = "Edição é obrigatória.")
        Long edicaoId,

        @NotNull(message = "Mês é obrigatório.")
        @Min(value = 1, message = "Mês deve ser maior ou igual a 1.")
        @Max(value = 12, message = "Mês deve ser menor ou igual a 12.")
        Integer mes,

        @NotNull(message = "Ano é obrigatório.")
        @Min(value = 2000, message = "Ano deve ser maior ou igual a 2000.")
        @Max(value = 2100, message = "Ano deve ser menor ou igual a 2100.")
        Integer ano,

        StatusCompraPlanejada status,

        PrioridadeCompra prioridade,

        @DecimalMin(value = "0.00", message = "Preço estimado não pode ser negativo.")
        BigDecimal precoEstimado,

        @Size(max = 1000, message = "Link de compra deve ter no máximo 1000 caracteres.")
        String linkCompra,

        @Size(max = 1000, message = "Observações devem ter no máximo 1000 caracteres.")
        String observacoes) {
}
