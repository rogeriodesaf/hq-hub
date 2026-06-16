package br.com.hqhub.dto;

import br.com.hqhub.entity.TipoLinkEdicao;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CadastroLinkEdicaoDTO(
        @NotNull(message = "Edição é obrigatória.")
        Long edicaoId,

        @NotNull(message = "Tipo do link é obrigatório.")
        TipoLinkEdicao tipo,

        @NotBlank(message = "Título do link é obrigatório.")
        @Size(max = 255, message = "Título do link deve ter no máximo 255 caracteres.")
        String titulo,

        @NotBlank(message = "URL é obrigatória.")
        @Size(max = 1000, message = "URL deve ter no máximo 1000 caracteres.")
        String url,

        @Size(max = 1000, message = "Observações devem ter no máximo 1000 caracteres.")
        String observacoes) {
}
