package br.com.hqhub.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

import br.com.hqhub.entity.EstadoConservacao;
import br.com.hqhub.entity.StatusLeitura;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record AtualizacaoItemColecaoDTO(
        @NotNull(message = "Estado de conservação é obrigatório.")
        EstadoConservacao estadoConservacao,

        LocalDate dataAquisicao,

        @DecimalMin(value = "0.00", message = "Preço pago não pode ser negativo.")
        BigDecimal precoPago,

        StatusLeitura statusLeitura,

        @Size(max = 1000, message = "Observações devem ter no máximo 1000 caracteres.")
        String observacoes) {
}
