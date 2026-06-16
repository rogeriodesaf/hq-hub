package br.com.hqhub.dto;

import java.math.BigDecimal;

public record ColecaoResumoDTO(
        long totalItens,
        long totalSeries,
        long totalEditoras,
        BigDecimal valorTotalPago) {
}
