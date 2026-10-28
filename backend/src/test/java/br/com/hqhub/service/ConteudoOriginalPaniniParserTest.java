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
}
