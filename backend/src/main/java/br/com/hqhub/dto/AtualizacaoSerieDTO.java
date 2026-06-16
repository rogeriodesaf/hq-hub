package br.com.hqhub.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record AtualizacaoSerieDTO(
        @NotBlank(message = "Título da série é obrigatório.")
        @Size(max = 255, message = "Título da série deve ter no máximo 255 caracteres.")
        String titulo,

        @Size(max = 1000, message = "Descrição da série deve ter no máximo 1000 caracteres.")
        String descricao,

        @Min(value = 1900, message = "Ano de início deve ser maior ou igual a 1900.")
        @Max(value = 2100, message = "Ano de início deve ser menor ou igual a 2100.")
        Integer anoInicio,

        @Min(value = 1900, message = "Ano de fim deve ser maior ou igual a 1900.")
        @Max(value = 2100, message = "Ano de fim deve ser menor ou igual a 2100.")
        Integer anoFim,

        @Min(value = 1, message = "Volume deve ser maior ou igual a 1.")
        Integer volume,

        @Min(value = 1, message = "Ordem cronológica deve ser maior ou igual a 1.")
        Integer ordemCronologica,

        @Size(max = 100, message = "Fonte externa deve ter no máximo 100 caracteres.")
        String fonteExterna,

        @Size(max = 255, message = "Id externo deve ter no máximo 255 caracteres.")
        String idExterno,

        @Size(max = 1000, message = "URL de origem deve ter no máximo 1000 caracteres.")
        String urlOrigem,

        @NotNull(message = "Editora é obrigatória.")
        Long editoraId) {
}
