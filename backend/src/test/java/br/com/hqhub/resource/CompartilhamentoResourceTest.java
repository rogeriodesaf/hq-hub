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
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.ItemOrdemLeituraRepository;
import br.com.hqhub.service.EdicaoService;
import jakarta.ws.rs.core.Response;

class CompartilhamentoResourceTest {
    private EdicaoService edicoes;
    private EdicaoRepository repositorioEdicoes;
    private ItemOrdemLeituraRepository itensGuia;
    private CompartilhamentoResource recurso;

    @BeforeEach
    void preparar() {
        edicoes = mock(EdicaoService.class);
        repositorioEdicoes = mock(EdicaoRepository.class);
        itensGuia = mock(ItemOrdemLeituraRepository.class);
        recurso = new CompartilhamentoResource(null, null, null, repositorioEdicoes, null, itensGuia, null, null, null,
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
            assertTrue(html.contains("https://api.hqhub.example/api/compartilhar/edicoes/42/imagem.jpg?v=2"));
            assertTrue(html.contains("https://api.hqhub.example/api/compartilhar/edicoes/42?v=2"));
        }
        verify(edicoes, times(1)).buscarPorId(42L);
    }

    @Test
    void usaCapaDoItemDoGuiaQuandoEdicaoNaoTemCapaPublica() {
        when(repositorioEdicoes.capaPublicaPorEdicao(42L)).thenReturn(java.util.Optional.empty());
        when(itensGuia.capaReferenciaPorEdicao(42L))
                .thenReturn(java.util.Optional.of("https://img.example/capa-guia.jpg"));

        assertEquals("https://img.example/capa-guia.jpg", recurso.capaEdicaoCompartilhamento(42L, null));
    }

    @Test
    void retornaPaginaPublica404ParaEdicaoInexistente() {
        when(edicoes.buscarPorId(999L)).thenThrow(new RecursoNaoEncontradoException("não encontrada"));

        try (Response resposta = recurso.compartilharEdicaoAmigavel(999L)) {
            assertEquals(404, resposta.getStatus());
            assertTrue(resposta.getEntity().toString().contains("Edição não encontrada"));
        }
    }

    @Test
    void usaLogoDosXMenNoCompartilhamentoDoGuiaMutante() {
        try (Response resposta = recurso.compartilharGuiaXMen()) {
            String html = resposta.getEntity().toString();

            assertEquals(200, resposta.getStatus());
            assertTrue(html.contains("/api/compartilhar/guias/ordem-de-leitura-mutante/imagem.jpg?v=4"));
            assertTrue(html.contains("/api/compartilhar/guias/xmen?v=4"));
            assertTrue(html.contains("og:image:alt\" content=\"Logotipo dos X-Men"));
            assertTrue(html.contains("https://hqhub.example/guia-de-leitura-app/ordem-de-leitura-mutante"));
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
