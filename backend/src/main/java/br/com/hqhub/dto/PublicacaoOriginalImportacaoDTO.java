package br.com.hqhub.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

import jakarta.validation.constraints.NotBlank;

public record PublicacaoOriginalImportacaoDTO(
        @NotBlank(message = "Serie original e obrigatoria.")
        String serieOriginal,

        @NotBlank(message = "Numero original e obrigatorio.")
        String numeroOriginal,

        Integer anoOriginal,
        String texto,
        String idComicVine,
        String urlComicVine,
        String urlCapa,
        String urlOrigem,
        String urlCompraAmazon,
        BigDecimal precoCompraAmazon,
        LocalDate dataCapturacaoPrecoCompraAmazon,
        String titulo,
        String nomeVolume,
        LocalDate dataCapa,
        LocalDate dataVenda,
        String descricaoOriginal,
        String descricaoPortugues) {
}
