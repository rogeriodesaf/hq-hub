package br.com.hqhub.dto;

import java.util.List;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;

public record ImportacaoCatalogoDTO(
        OrigemImportacaoCatalogoDTO origem,

        @Valid
        @NotNull(message = "Série brasileira é obrigatória.")
        SerieBrasileiraImportacaoDTO serieBrasileira,

        Integer totalEdicoes,
        Integer totalHistorias,
        List<String> avisos,

        @Valid
        @NotNull(message = "Edições são obrigatórias.")
        List<EdicaoImportacaoDTO> edicoes) {
}
