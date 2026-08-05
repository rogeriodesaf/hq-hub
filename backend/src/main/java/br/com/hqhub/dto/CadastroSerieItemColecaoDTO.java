package br.com.hqhub.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

import br.com.hqhub.entity.EstadoConservacao;
import br.com.hqhub.entity.StatusLeitura;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CadastroSerieItemColecaoDTO(
        @NotNull(message = "Serie e obrigatoria.")
        Long serieId,

        @NotNull(message = "Estado de conservacao e obrigatorio.")
        EstadoConservacao estadoConservacao,

        LocalDate dataAquisicao,

        @DecimalMin(value = "0.00", message = "Preco pago nao pode ser negativo.")
        BigDecimal precoPago,

        StatusLeitura statusLeitura,

        @Size(max = 1000, message = "Observacoes devem ter no maximo 1000 caracteres.")
        String observacoes) {
}
