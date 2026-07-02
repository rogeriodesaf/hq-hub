package br.com.hqhub.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;

public record CadastroSerieComEdicoesDTO(
        @Valid
        @NotNull(message = "Dados da série são obrigatórios.")
        CadastroSerieDTO serie,

        @Valid
        GeracaoAutomaticaEdicoesDTO geracaoAutomaticaEdicoes) {
}
