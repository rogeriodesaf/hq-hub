package br.com.hqhub.resource;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import org.junit.jupiter.api.Test;

import br.com.hqhub.dto.EstatisticasCatalogoDTO;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.SerieRepository;
import jakarta.ws.rs.core.Response;

class CatalogoPublicoResourceTest {

    @Test
    void retornaTotaisAtuaisDoCatalogoComCacheCurto() {
        SerieRepository series = mock(SerieRepository.class);
        EdicaoRepository edicoes = mock(EdicaoRepository.class);
        when(series.count()).thenReturn(3_946L);
        when(edicoes.count()).thenReturn(34_089L);

        CatalogoPublicoResource recurso = new CatalogoPublicoResource(series, edicoes);

        try (Response resposta = recurso.obterEstatisticas()) {
            assertEquals(200, resposta.getStatus());
            assertEquals(new EstatisticasCatalogoDTO(3_946L, 34_089L), resposta.getEntity());
            assertTrue(resposta.getHeaderString("Cache-Control").contains("max-age=30"));
        }
    }
}
