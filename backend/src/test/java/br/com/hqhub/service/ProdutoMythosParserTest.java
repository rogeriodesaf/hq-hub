package br.com.hqhub.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;

class ProdutoMythosParserTest {
    private final ProdutoMythosParser parser = new ProdutoMythosParser();

    @Test
    void extraiProdutoJuliaVol quatroDaLojaMythos() {
        String html = """
                <meta property="og:title" content="JÚLIA VOL. 04 -Quadrinhos, mangás e muita leitura">
                <meta property="og:description" content="Capa cartão · Miolo offset 132 páginas · PB Formato: 16 x 21 cm">
                <meta property="og:image" content="https://images.tcdn.com.br/julia.jpg">
                <script type="application/ld+json">{"@type":"Product","name":"JÚLIA VOL. 04","image":"https://images.tcdn.com.br/julia.jpg","sku":"1709619","gtin":"9788578675059","brand":{"name":"MYTHOS EDITORA"},"offers":{"price":"44.9"}}</script>
                <table><tr><td data-th="Código de barras">9788578675059</td></tr></table>
                """;

        ProdutoMythosParser.Produto produto = parser.extrair(html);

        assertEquals("JÚLIA", produto.serie());
        assertEquals("04", produto.numero());
        assertEquals("1709619", produto.sku());
        assertEquals("9788578675059", produto.codigoBarras());
        assertEquals("MYTHOS EDITORA", produto.marca());
        assertEquals(132, produto.quantidadePaginas());
        assertEquals("16 x 21 cm", produto.formato());
        assertTrue(produto.urlCapa().endsWith("julia.jpg"));
    }
}
