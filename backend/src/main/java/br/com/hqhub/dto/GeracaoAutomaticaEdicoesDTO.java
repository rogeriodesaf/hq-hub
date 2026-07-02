package br.com.hqhub.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

public record GeracaoAutomaticaEdicoesDTO(
        @Min(value = 1, message = "Quantidade de edições deve ser maior que zero.")
        @Max(value = 500, message = "Quantidade máxima para geração automática é 500.")
        Integer quantidade,

        @Min(value = 0, message = "Número inicial deve ser maior ou igual a zero.")
        Integer numeroInicial,

        @Min(value = 1, message = "Intervalo da numeração deve ser maior que zero.")
        Integer intervalo) {
}
