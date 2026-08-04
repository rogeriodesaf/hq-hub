package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Positive;

public record GeracaoRascunhoGcdDTO(
        @NotBlank(message = "Selecione uma serie do GCD.") String apiUrlSerie,
        @NotBlank(message = "Titulo da serie e obrigatorio.") String tituloSerie,
        String editora,
        Integer volume,
        @Positive(message = "A edicao inicial deve ser maior que zero.") Integer inicio,
        @Positive(message = "Quantidade de edicoes deve ser maior que zero.")
        @Max(value = 25, message = "Colete no maximo 25 edicoes por lote.") Integer quantidade) {
}
