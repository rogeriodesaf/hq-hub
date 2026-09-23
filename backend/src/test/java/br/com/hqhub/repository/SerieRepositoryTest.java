package br.com.hqhub.repository;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.stream.Stream;

import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import br.com.hqhub.entity.Serie;
import jakarta.persistence.EntityManager;
import jakarta.persistence.Query;

class SerieRepositoryTest {

    @Test
    void buscaSeriePelaMesmaIdentidadeDoGatilhoDeDuplicidade() {
        EntityManager entityManager = mock(EntityManager.class);
        Query query = mock(Query.class);
        Serie existente = new Serie();
        ArgumentCaptor<String> sql = ArgumentCaptor.forClass(String.class);

        when(entityManager.createNativeQuery(anyString(), eq(Serie.class))).thenReturn(query);
        when(query.setParameter(anyString(), org.mockito.ArgumentMatchers.any())).thenReturn(query);
        when(query.setMaxResults(1)).thenReturn(query);
        when(query.getResultStream()).thenReturn(Stream.of(existente));

        SerieRepository repository = new SerieRepository(entityManager);
        assertEquals(existente, repository.buscarPorTituloEEditoraEVolume("Marvel Saga: X-Men", 7L, null).orElseThrow());

        verify(entityManager).createNativeQuery(sql.capture(), eq(Serie.class));
        assertTrue(sql.getValue().contains("hqhub_normalizar_titulo_serie(s.titulo)"));
        assertTrue(sql.getValue().contains("hqhub_normalizar_titulo_serie(:titulo)"));
        assertTrue(sql.getValue().contains("'marvelsaga'"));
        verify(query).setParameter("editoraId", 7L);
        verify(query).setParameter("volume", 0);
        verify(query).setParameter("titulo", "Marvel Saga: X-Men");
    }

    @Test
    void listaTodasAsSeriesComAIdentidadeDuplicada() {
        EntityManager entityManager = mock(EntityManager.class);
        Query query = mock(Query.class);
        Serie primeira = new Serie();
        Serie segunda = new Serie();

        when(entityManager.createNativeQuery(anyString(), eq(Serie.class))).thenReturn(query);
        when(query.setParameter(anyString(), org.mockito.ArgumentMatchers.any())).thenReturn(query);
        when(query.getResultStream()).thenReturn(Stream.of(primeira, segunda));

        SerieRepository repository = new SerieRepository(entityManager);
        List<Serie> encontradas = repository.buscarTodasPorTituloEEditoraEVolume("X-Men", 7L, 2);

        assertEquals(List.of(primeira, segunda), encontradas);
        verify(query).setParameter("editoraId", 7L);
        verify(query).setParameter("volume", 2);
        verify(query).setParameter("titulo", "X-Men");
    }
}
