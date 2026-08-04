package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;

public record GeracaoRascunhoImportacaoDTO(
        @NotBlank(message = "URL do Guia e obrigatoria.")
        String urlGuia,

        String urlPaniniInicial,

        @Positive(message = "Quantidade de edicoes deve ser maior que zero.")
        Integer quantidade,

        @NotBlank(message = "Titulo da serie e obrigatorio.")
        String tituloSerie,

        String fase,

        @NotBlank(message = "Editora e obrigatoria.")
        String editora,

        Integer volume) {
}
