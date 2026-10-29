package br.com.hqhub.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CadastroEdicaoBrasileiraPaniniDTO(
        @NotBlank @Size(max = 1000) String urlPanini,
        Long serieId,
        Boolean criarNovaSerie,
        @Size(max = 255) String tituloSerie,
        @Min(1) Integer volumeSerie,
        @NotBlank @Size(max = 50) String numero,
        @Size(max = 255) String tituloEdicao,
        @Size(max = 2000) String descricao,
        LocalDate dataPublicacao,
        @Size(max = 100) String codigoBarras,
        @Min(1) Integer quantidadePaginas,
        @DecimalMin("0.00") BigDecimal precoCapa,
        @Size(max = 100) String formato) {
}
