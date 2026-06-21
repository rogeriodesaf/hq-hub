package br.com.hqhub.dto;

import java.math.BigDecimal;

public record EstatisticasPublicasColecaoDTO(
        long totalItens,
        long totalSeries,
        long totalEditoras,
        long totalLidos,
        long totalNaoLidos,
        BigDecimal valorTotalPago) {
}
