package br.com.hqhub.resource;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import br.com.hqhub.dto.EdicaoRespostaDTO;
import br.com.hqhub.dto.EditoraResumoDTO;
import br.com.hqhub.dto.SerieResumoDTO;
import br.com.hqhub.dto.SerieRespostaDTO;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.ItemOrdemLeituraRepository;
import br.com.hqhub.service.EdicaoService;
import br.com.hqhub.service.SerieService;
import jakarta.ws.rs.core.Response;

class CompartilhamentoResourceTest {
    private EdicaoService edicoes;
    private EdicaoRepository repositorioEdicoes;
    private ItemOrdemLeituraRepository itensGuia;
    private SerieService series;
    private CompartilhamentoResource recurso;

    @BeforeEach
    void preparar() {
        edicoes = mock(EdicaoService.class);
        repositorioEdicoes = mock(EdicaoRepository.class);
        itensGuia = mock(ItemOrdemLeituraRepository.class);
        series = mock(SerieService.class);
        recurso = new CompartilhamentoResource(null, null, null, repositorioEdicoes, null, itensGuia, null, null, null,
                edicoes, series, null, null);
        recurso.urlBase = "https://hqhub.example";
        recurso.apiUrlPublica = "https://api.hqhub.example";
        recurso.urlCompartilhamentoPublica = "https://share.hqhub.example/api/compartilhar";
    }

    @Test
    void geraMetadadosDinamicosEscapadosParaEdicao() {
        when(edicoes.buscarPorId(42L)).thenReturn(edicao(42L, "A Saga <Especial>", "1&2"));

        try (Response resposta = recurso.compartilharEdicaoAmigavel(42L)) {
            String html = resposta.getEntity().toString();
            assertEquals(200, resposta.getStatus());
            assertTrue(html.contains("og:type\" content=\"article"));
            assertTrue(html.contains("twitter:card\" content=\"summary_large_image"));
            assertTrue(html.contains("A Saga &lt;Especial&gt; #1&amp;2 | Coleciona HQ"));
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
    void geraMetadadosEAbreCatalogoDaSerieCompleta() {
        when(series.buscarPorId(7L)).thenReturn(serie(7L, "Biblioteca <Dylan Dog>", 1));
        when(repositorioEdicoes.contarPorSerie(7L)).thenReturn(2L);

        try (Response resposta = recurso.compartilharSerie(7L)) {
            String html = resposta.getEntity().toString();

            assertEquals(200, resposta.getStatus());
            assertTrue(html.contains("og:type\" content=\"website"));
            assertTrue(html.contains("Biblioteca &lt;Dylan Dog&gt; · Volume 1 | Coleciona HQ"));
            assertTrue(html.contains("Panini · 2 edições."));
            assertTrue(html.contains("https://share.hqhub.example/api/compartilhar/series/7/imagem.jpg?v=2"));
            assertTrue(html.contains("https://share.hqhub.example/api/compartilhar/series/7?v=2"));
            assertTrue(html.contains("https://hqhub.example/catalogo?serieId=7"));
        }
    }

    @Test
    void retornaPaginaPublica404ParaSerieInexistente() {
        when(series.buscarPorId(999L)).thenThrow(new RecursoNaoEncontradoException("não encontrada"));

        try (Response resposta = recurso.compartilharSerie(999L)) {
            assertEquals(404, resposta.getStatus());
            assertTrue(resposta.getEntity().toString().contains("Coleção não encontrada"));
        }
    }

    @Test
    void usaPrimeiraCapaDisponivelDaSerie() {
        when(repositorioEdicoes.primeiraCapaPorSerie(7L))
                .thenReturn(Optional.of("https://img.example/dylan-dog.jpg"));

        assertEquals("https://img.example/dylan-dog.jpg", recurso.capaSerieCompartilhamento(7L));
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

    @Test
    void migraUrlLegadaDoFrontendParaDominioPersonalizado() {
        recurso.urlBase = "https://hqhub-frontend.onrender.com/";

        try (Response resposta = recurso.compartilharGuiaXMen()) {
            String html = resposta.getEntity().toString();

            assertTrue(html.contains("https://hqhub.space/guia-de-leitura-app/ordem-de-leitura-mutante"));
            assertFalse(html.contains("https://hqhub-frontend.onrender.com"));
        }
    }

    private EdicaoRespostaDTO edicao(Long id, String serie, String numero) {
        return new EdicaoRespostaDTO(id, numero, null, null, null, null,
                "Conheça esta edição.", null, null, null, LocalDate.of(2021, 5, 1),
                "https://img.example/capa.jpg", null, null, null, null, null,
                null, null, null, null,
                new SerieResumoDTO(7L, serie, new EditoraResumoDTO(3L, "Panini")), null, null);
    }

    private SerieRespostaDTO serie(Long id, String titulo, Integer volume) {
        return new SerieRespostaDTO(id, titulo, null, 2022, null, volume, null,
                null, null, null, new EditoraResumoDTO(3L, "Panini"),
                LocalDateTime.now(), LocalDateTime.now());
    }
}
