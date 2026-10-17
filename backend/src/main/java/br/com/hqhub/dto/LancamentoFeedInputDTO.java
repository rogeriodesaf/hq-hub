package br.com.hqhub.dto;

import java.time.LocalDate;

import jakarta.validation.constraints.NotNull;

public record LancamentoFeedInputDTO(
        @NotNull(message = "Selecione a edicao do lancamento.")
        Long edicaoId,
        LocalDate dataLancamento) {
}
