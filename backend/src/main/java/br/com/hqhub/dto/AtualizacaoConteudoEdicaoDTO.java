package br.com.hqhub.dto;

import br.com.hqhub.entity.TipoConteudoEdicao;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record AtualizacaoConteudoEdicaoDTO(
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
