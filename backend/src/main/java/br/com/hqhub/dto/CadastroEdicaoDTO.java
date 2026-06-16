package br.com.hqhub.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CadastroEdicaoDTO(
        @NotBlank(message = "Número da edição é obrigatório.")
        @Size(max = 50, message = "Número da edição deve ter no máximo 50 caracteres.")
        String numero,

        @Size(max = 255, message = "Título da edição deve ter no máximo 255 caracteres.")
        String titulo,

        @Size(max = 2000, message = "Descrição da edição deve ter no máximo 2000 caracteres.")
        String descricao,

        LocalDate dataPublicacao,

        @Size(max = 1000, message = "URL da capa deve ter no máximo 1000 caracteres.")
        String urlCapa,

        @Size(max = 100, message = "Código de barras deve ter no máximo 100 caracteres.")
        String codigoBarras,

        @Min(value = 1, message = "Quantidade de páginas deve ser maior que zero.")
        Integer quantidadePaginas,

        @DecimalMin(value = "0.00", message = "Preço de capa não pode ser negativo.")
        BigDecimal precoCapa,

        @Size(max = 100, message = "Fonte externa deve ter no máximo 100 caracteres.")
        String fonteExterna,

        @Size(max = 255, message = "Id externo deve ter no máximo 255 caracteres.")
        String idExterno,

        @Size(max = 1000, message = "URL de origem deve ter no máximo 1000 caracteres.")
        String urlOrigem,

        @NotNull(message = "Série é obrigatória.")
        Long serieId) {
}
