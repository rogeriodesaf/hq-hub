package br.com.hqhub.dto;

import java.math.BigDecimal;

public record PreviaProdutoMythosDTO(String urlMythos, String tituloProduto, ProdutoMythosDTO produto) {
    public record ProdutoMythosDTO(
            String tituloSerieSugerido,
            String numeroSugerido,
            String descricao,
            String urlCapa,
            String sku,
            String codigoBarras,
            BigDecimal preco,
            Integer quantidadePaginas,
            String formato,
            String marca) {}
}
