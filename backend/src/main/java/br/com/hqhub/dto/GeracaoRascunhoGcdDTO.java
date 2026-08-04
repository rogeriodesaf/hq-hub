package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;

public record GeracaoRascunhoGcdDTO(
        @NotBlank(message = "Selecione uma serie do GCD.") String apiUrlSerie,
        @NotBlank(message = "Titulo da serie e obrigatorio.") String tituloSerie,
        String editora,
        Integer volume,
        @Positive(message = "Quantidade de edicoes deve ser maior que zero.") Integer quantidade) {
}
