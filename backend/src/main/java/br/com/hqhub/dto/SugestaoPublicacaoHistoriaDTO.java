package br.com.hqhub.dto;

import br.com.hqhub.entity.TipoPublicacaoHistoria;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record SugestaoPublicacaoHistoriaDTO(
        @NotNull(message = "Edição é obrigatória.")
        Long edicaoId,

        @NotNull(message = "Tipo de publicação da história é obrigatório.")
        TipoPublicacaoHistoria tipoPublicacaoHistoria,

        @Size(max = 255, message = "Fonte de informação deve ter no máximo 255 caracteres.")
        String fonteInformacao,

        @Size(max = 1000, message = "URL da fonte de informação deve ter no máximo 1000 caracteres.")
        String urlFonteInformacao,

        @Size(max = 1000, message = "Observação deve ter no máximo 1000 caracteres.")
        String observacao) {
}
