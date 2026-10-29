package br.com.hqhub.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

import org.junit.jupiter.api.Test;

class ConteudoOriginalPaniniParserTest {

    private final ConteudoOriginalPaniniParser parser = new ConteudoOriginalPaniniParser();

    @Test
    void extraiEInterpretaConteudoOriginalDaPaginaPanini() {
        String html = """
                <meta property="og:title" content="Homem-Aranha: A Saga do Clone - Vol. 10">
                <table><tr><td class="col data" data-th="Conte&#xFA;do&#x20;original"><p><i>
                Spider-Man Team-Up (1995) 3; Amazing Spider-Man Annual ’96;
                The Sensational Spider-Man (1995) 4; Amazing Spider-Man (1963) 411 (Blood Brothers, 2
                </i></p></td></tr></table>
                """;

        var pagina = parser.extrair(html);

        assertEquals("Homem-Aranha: A Saga do Clone - Vol. 10", pagina.titulo());
        assertEquals(4, pagina.referencias().size());
        assertEquals("Spider-Man Team-Up", pagina.referencias().get(0).serie());
        assertEquals(1995, pagina.referencias().get(0).anoSerie());
        assertEquals("3", pagina.referencias().get(0).numero());
        assertEquals("Amazing Spider-Man Annual", pagina.referencias().get(1).serie());
        assertNull(pagina.referencias().get(1).anoSerie());
        assertEquals("1996", pagina.referencias().get(1).numero());
        assertEquals("Blood Brothers, 2", pagina.referencias().get(3).complemento());
    }

    @Test
    void desdobraIntervaloEmEdicoesIndividuais() {
        String html = "<td data-th=\"Conte&#xFA;do&#x20;original\">Spectacular Spider-Man (1976) 232-233</td>";

        var referencias = parser.extrair(html).referencias();

        assertEquals(2, referencias.size());
        assertEquals("232", referencias.get(0).numero());
        assertEquals("233", referencias.get(1).numero());
    }

    @Test
    void extraiDadosDoProdutoParaCadastrarEdicaoBrasileira() {
        String html = """
                <meta property="og:title" content="A Saga Dos X-Men 16 (52)">
                <meta property="og:description" content="Descri&#xE7;&#xE3;o oficial">
                <script type="application/ld+json">
                {"@type":"Product","sku":"ASAXM052","isbn":"9786525945194",
                 "image":["https://cdn.panini.test/capa.webp"],
                 "brand":{"@type":"Brand","name":"Marvel Comics"},
                 "offers":{"price":"47.90","availabilityStarts":"2026-10-30"}}
                </script>
                <td data-th="Conte&#xFA;do&#x20;original">Cable (1993) 6-8; X-Men (1991) 27</td>
                <td data-th="N&#xFA;mero de p&#xE1;ginas">160</td>
                <td data-th="Formato">17 x 26 cm</td>
                <td data-th="Autores">Aron Wiesenfeld, Dwayne Turner; Fabian Nicieza</td>
                """;

        var pagina = parser.extrair(html);
        var produto = pagina.produto();

        assertEquals("A Saga Dos X-Men", produto.tituloSerieSugerido());
        assertEquals("16", produto.numeroSugerido());
        assertEquals("52", produto.numeroAlternativo());
        assertEquals("ASAXM052", produto.sku());
        assertEquals("9786525945194", produto.isbn());
        assertEquals("https://cdn.panini.test/capa.webp", produto.urlCapa());
        assertEquals("Marvel Comics", produto.marca());
        assertEquals("47.90", produto.preco().toPlainString());
        assertEquals("2026-10-30", produto.dataDisponibilidade().toString());
        assertEquals(160, produto.quantidadePaginas());
        assertEquals("17 x 26 cm", produto.formato());
        assertEquals(java.util.List.of("Aron Wiesenfeld", "Dwayne Turner", "Fabian Nicieza"), produto.autores());
        assertEquals(4, pagina.referencias().size());
    }
}
