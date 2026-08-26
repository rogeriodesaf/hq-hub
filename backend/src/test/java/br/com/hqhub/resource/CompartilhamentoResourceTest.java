package br.com.hqhub.resource;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.time.LocalDate;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import br.com.hqhub.dto.EdicaoRespostaDTO;
import br.com.hqhub.dto.EditoraResumoDTO;
import br.com.hqhub.dto.SerieResumoDTO;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.service.EdicaoService;
import jakarta.ws.rs.core.Response;

class CompartilhamentoResourceTest {
    private EdicaoService edicoes;
    private CompartilhamentoResource recurso;

    @BeforeEach
    void preparar() {
        edicoes = mock(EdicaoService.class);
        recurso = new CompartilhamentoResource(null, null, null, null, null, null, null, null,
                edicoes, null, null);
        recurso.urlBase = "https://hqhub.example";
        recurso.apiUrlPublica = "https://api.hqhub.example";
    }

    @Test
    void geraMetadadosDinamicosEscapadosParaEdicao() {
        when(edicoes.buscarPorId(42L)).thenReturn(edicao(42L, "A Saga <Especial>", "1&2"));

        try (Response resposta = recurso.compartilharEdicaoAmigavel(42L)) {
            String html = resposta.getEntity().toString();
            assertEquals(200, resposta.getStatus());
            assertTrue(html.contains("og:type\" content=\"article"));
            assertTrue(html.contains("twitter:card\" content=\"summary_large_image"));
            assertTrue(html.contains("A Saga &lt;Especial&gt; #1&amp;2 | HQ-HUB"));
            assertTrue(html.contains("Panini · 2021."));
            assertTrue(html.contains("https://api.hqhub.example/api/compartilhar/edicoes/42/imagem.jpg?v=1"));
            assertTrue(html.contains("https://api.hqhub.example/api/compartilhar/edicoes/42?v=1"));
        }
        verify(edicoes, times(1)).buscarPorId(42L);
    }

    @Test
    void retornaPaginaPublica404ParaEdicaoInexistente() {
        when(edicoes.buscarPorId(999L)).thenThrow(new RecursoNaoEncontradoException("não encontrada"));

        try (Response resposta = recurso.compartilharEdicaoAmigavel(999L)) {
            assertEquals(404, resposta.getStatus());
            assertTrue(resposta.getEntity().toString().contains("Edição não encontrada"));
        }
    }

    private EdicaoRespostaDTO edicao(Long id, String serie, String numero) {
        return new EdicaoRespostaDTO(id, numero, null, null, null, null,
                "Conheça esta edição.", null, null, null, LocalDate.of(2021, 5, 1),
                "https://img.example/capa.jpg", null, null, null, null, null,
                null, null, null, null,
                new SerieResumoDTO(7L, serie, new EditoraResumoDTO(3L, "Panini")), null, null);
    }
}
