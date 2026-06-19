package br.com.hqhub.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;

public record HistoriaImportacaoDTO(
        Integer ordem,

        @NotBlank(message = "Título em português da história é obrigatório.")
        String tituloPortugues,

        String tituloOriginal,
        Integer quantidadePaginas,
        String resumo,

        @Valid
        PublicacaoOriginalImportacaoDTO publicacaoOriginal) {
}
