package br.com.hqhub.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

public record CalculoInflacaoRespostaDTO(
        BigDecimal valorOriginal,
        BigDecimal valorCorrigido,
        BigDecimal fatorCorrecao,
        BigDecimal percentualAcumulado,
        LocalDate dataReferencia,
        LocalDate dataCalculo,
        String indice,
        String observacao) {
}
