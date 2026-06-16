package br.com.hqhub.dto;

import br.com.hqhub.entity.TipoRelacionamentoSerie;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CadastroRelacionamentoSerieDTO(
        @NotNull(message = "Série de origem é obrigatória.")
        Long serieOrigemId,

        @NotNull(message = "Série de destino é obrigatória.")
        Long serieDestinoId,

        @NotNull(message = "Tipo de relacionamento é obrigatório.")
        TipoRelacionamentoSerie tipo,

        @Size(max = 500, message = "Observações devem ter no máximo 500 caracteres.")
        String observacoes) {
}
