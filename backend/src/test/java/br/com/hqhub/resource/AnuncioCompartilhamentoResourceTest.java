package br.com.hqhub.resource;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import org.junit.jupiter.api.Test;

import br.com.hqhub.dto.AnuncioPublicoDTO;
import br.com.hqhub.entity.EstadoConservacao;
import br.com.hqhub.entity.TipoAnuncio;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.service.AnuncioService;
import jakarta.ws.rs.core.Response;

class AnuncioCompartilhamentoResourceTest {
    private final AnuncioService service = mock(AnuncioService.class);
    private final AnuncioCompartilhamentoResource recurso = new AnuncioCompartilhamentoResource(service);

    @Test
    void anuncioDeVendaUsaFotoRealEPrecoNoHtmlInicial() {
        when(service.buscarAtivoPublico(12L)).thenReturn(anuncio(12L, "Batman #12", TipoAnuncio.VENDA,
                new BigDecimal("29.90"), "https://img.example/exemplar.jpg", "https://img.example/capa.jpg"));
        try (Response resposta = recurso.compartilhar(12L)) {
            String html = resposta.getEntity().toString();
            assertEquals(200, resposta.getStatus());
            assertTrue(html.contains("Batman #12 · Venda · R$"));
            assertTrue(html.contains("og:image\" content=\"https://img.example/exemplar.jpg"));
            assertTrue(html.contains("Conservação: muito bom · Anunciante: Ana"));
            assertTrue(html.contains("rel=\"canonical\" href=\"https://hqhub.space/classificados/anuncio/12"));
            assertTrue(html.indexOf("og:title") < html.indexOf("<script>"));
        }
    }

    @Test
    void anuncioDeTrocaUsaCapaSemInventarPreco() {
        when(service.buscarAtivoPublico(34L)).thenReturn(anuncio(34L, "Superman #3", TipoAnuncio.TROCA,
                null, null, "https://img.example/superman.jpg"));
        try (Response resposta = recurso.compartilhar(34L)) {
            String html = resposta.getEntity().toString();
            assertEquals(200, resposta.getStatus());
            assertTrue(html.contains("Superman #3 · Troca | HQ-HUB"));
            assertTrue(html.contains("og:image\" content=\"https://img.example/superman.jpg"));
            assertFalse(html.contains("Valor a combinar"));
            assertFalse(html.contains("classificados-hqs.jpg"));
        }
    }

    @Test
    void capaWebpUsaImagemJpegDoMesmoDominioNaPrevia() {
        when(service.buscarAtivoPublico(15L)).thenReturn(anuncio(15L, "X-Men #2", TipoAnuncio.VENDA,
                null, null, "https://d14d9vp3wdof84.cloudfront.net/image/capa/-S265-FWEBP"));
        try (Response resposta = recurso.compartilhar(15L)) {
            String html = resposta.getEntity().toString();
            assertTrue(html.contains("og:image\" content=\"https://hqhub.space/classificados/anuncio/15/imagem.jpg\""));
            assertTrue(html.contains("og:image:secure_url\" content=\"https://hqhub.space/classificados/anuncio/15/imagem.jpg\""));
        }
    }

    @Test
    void anuncioInativoNaoExibeMetadadosAntigos() {
        when(service.buscarAtivoPublico(99L)).thenThrow(new RecursoNaoEncontradoException("Indisponível"));
        try (Response resposta = recurso.compartilhar(99L)) {
            assertEquals(404, resposta.getStatus());
            assertTrue(resposta.getEntity().toString().contains("Anúncio indisponível"));
            assertFalse(resposta.getEntity().toString().contains("og:image"));
        }
    }

    @Test
    void arteGenericaSoApareceQuandoNaoHaFotoNemCapa() {
        when(service.buscarAtivoPublico(56L)).thenReturn(anuncio(56L, "Batman #1", TipoAnuncio.VENDA_E_TROCA,
                null, null, null));
        try (Response resposta = recurso.compartilhar(56L)) {
            String html = resposta.getEntity().toString();
            assertTrue(html.contains("Batman #1 · Venda ou troca | HQ-HUB"));
            assertTrue(html.contains("og:image\" content=\"https://hqhub.space/assets/classificados-hqs.jpg?v=2"));
        }
    }

    private AnuncioPublicoDTO anuncio(Long id, String titulo, TipoAnuncio tipo, BigDecimal preco, String foto, String capa) {
        LocalDateTime agora = LocalDateTime.of(2026, 9, 16, 10, 0);
        return new AnuncioPublicoDTO(id, titulo, capa, foto, "Ana", tipo, preco, EstadoConservacao.MUITO_BOM,
                null, null, null, null, agora);
    }
}
