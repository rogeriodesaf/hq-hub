package br.com.hqhub.dto;

import br.com.hqhub.entity.TipoConteudoEdicao;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CadastroConteudoEdicaoDTO(
        @NotNull(message = "Edição é obrigatória.")
        Long edicaoId,

        @NotNull(message = "História é obrigatória.")
        Long historiaId,

        @NotNull(message = "Ordem é obrigatória.")
        Integer ordem,

        String tituloUsado,

        Integer paginaInicio,

        Integer paginaFim,

        Integer quantidadePaginas,

        @NotNull(message = "Tipo de conteúdo é obrigatório.")
        TipoConteudoEdicao tipo,

        @Size(max = 1000, message = "Observações devem ter no máximo 1000 caracteres.")
        String observacoes) {
}
