package br.com.hqhub.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

public record LancamentoFeedDTO(
        Long edicaoId,
        Long serieId,
        String titulo,
        String numero,
        String editora,
        String urlCapa,
        LocalDate dataLancamento,
        BigDecimal precoCapa) {
}
