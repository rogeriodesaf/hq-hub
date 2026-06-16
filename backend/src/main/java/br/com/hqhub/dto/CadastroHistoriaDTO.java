package br.com.hqhub.dto;

import br.com.hqhub.entity.TipoConteudoEdicao;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CadastroHistoriaDTO(
        @NotBlank(message = "Título é obrigatório.")
        String titulo,

        String tituloOriginal,

        @Size(max = 2000, message = "Descrição deve ter no máximo 2000 caracteres.")
        String descricao,

        Integer quantidadePaginas,

        @NotNull(message = "Tipo de conteúdo é obrigatório.")
        TipoConteudoEdicao tipo,

        @Size(max = 100, message = "Fonte externa deve ter no máximo 100 caracteres.")
        String fonteExterna,

        @Size(max = 100, message = "ID externo deve ter no máximo 100 caracteres.")
        String idExterno,

        @Size(max = 1000, message = "URL de origem deve ter no máximo 1000 caracteres.")
        String urlOrigem) {
}
