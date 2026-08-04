package br.com.hqhub.dto;

import br.com.hqhub.entity.TipoConteudoEdicao;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

public record ItemHistoriaLoteDTO(
        @Positive(message = "Ordem deve ser maior que zero.")
        Integer ordem,

        @NotBlank(message = "Título é obrigatório.")
        String titulo,

        String tituloOriginal,

        @Positive(message = "Quantidade de páginas deve ser maior que zero.")
        Integer quantidadePaginas,

        @NotNull(message = "Tipo de conteúdo é obrigatório.")
        TipoConteudoEdicao tipo,

        @Size(max = 2000, message = "Resumo deve ter no máximo 2000 caracteres.")
        String resumo) {
}
