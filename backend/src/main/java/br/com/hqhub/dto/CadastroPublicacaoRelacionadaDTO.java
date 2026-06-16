package br.com.hqhub.dto;

import br.com.hqhub.entity.TipoPublicacaoRelacionada;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CadastroPublicacaoRelacionadaDTO(
        @NotNull(message = "Edição de origem é obrigatória.")
        Long edicaoOrigemId,

        @NotNull(message = "Edição de destino é obrigatória.")
        Long edicaoDestinoId,

        @NotNull(message = "Tipo de publicação relacionada é obrigatório.")
        TipoPublicacaoRelacionada tipo,

        @Size(max = 100, message = "Fonte externa deve ter no máximo 100 caracteres.")
        String fonteExterna,

        @Size(max = 1000, message = "URL de origem deve ter no máximo 1000 caracteres.")
        String urlOrigem,

        @Size(max = 1000, message = "Observações devem ter no máximo 1000 caracteres.")
        String observacoes) {
}
