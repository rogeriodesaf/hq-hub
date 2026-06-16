package br.com.hqhub.dto;

import java.math.BigDecimal;

public record SerieCompletudeDTO(
        SerieResumoDTO serie,
        long totalEdicoes,
        long totalPossuidas,
        long totalFaltantes,
        BigDecimal percentualCompleto) {
}
