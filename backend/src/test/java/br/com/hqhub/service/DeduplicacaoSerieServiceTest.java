package br.com.hqhub.service;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.Test;

import br.com.hqhub.entity.Editora;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.Serie;
import br.com.hqhub.mapper.SerieMapper;
import br.com.hqhub.repository.SerieRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.Query;
import jakarta.persistence.TypedQuery;

class DeduplicacaoSerieServiceTest {

    @Test
    void removeExatamenteASerieSelecionadaQuandoExisteDuplicata() {
        SerieRepository repository = mock(SerieRepository.class);
        EntityManager entityManager = mock(EntityManager.class);
        Query nativeQuery = mock(Query.class);
        @SuppressWarnings("unchecked")
        TypedQuery<Edicao> edicoesQuery = mock(TypedQuery.class);
        Serie descartada = serie(20L);
        Serie mantida = serie(10L);

        when(repository.findByIdOptional(20L)).thenReturn(Optional.of(descartada));
        when(repository.buscarTodasPorTituloEEditoraEVolume("Batman", 3L, 1))
                .thenReturn(List.of(mantida, descartada));
        when(entityManager.createQuery(anyString(), org.mockito.ArgumentMatchers.eq(Edicao.class)))
                .thenReturn(edicoesQuery);
        when(edicoesQuery.setParameter("serieId", 20L)).thenReturn(edicoesQuery);
        when(edicoesQuery.getResultList()).thenReturn(List.of());
        when(entityManager.createNativeQuery(anyString())).thenReturn(nativeQuery);
        when(nativeQuery.setParameter(anyString(), org.mockito.ArgumentMatchers.any())).thenReturn(nativeQuery);
        when(nativeQuery.executeUpdate()).thenReturn(0);
        when(entityManager.contains(descartada)).thenReturn(true);

        DeduplicacaoSerieService service = new DeduplicacaoSerieService(
                repository,
                mock(SerieMapper.class),
                mock(DeduplicacaoEdicaoService.class),
                entityManager);

        assertTrue(service.removerSelecionadaSeDuplicada(20L));
        verify(entityManager).remove(descartada);
        verify(entityManager).flush();
    }

    @Test
    void naoRemoveTituloSemDuplicata() {
        SerieRepository repository = mock(SerieRepository.class);
        EntityManager entityManager = mock(EntityManager.class);
        Serie unica = serie(20L);
        when(repository.findByIdOptional(20L)).thenReturn(Optional.of(unica));
        when(repository.buscarTodasPorTituloEEditoraEVolume("Batman", 3L, 1)).thenReturn(List.of(unica));

        DeduplicacaoSerieService service = new DeduplicacaoSerieService(
                repository,
                mock(SerieMapper.class),
                mock(DeduplicacaoEdicaoService.class),
                entityManager);

        assertFalse(service.removerSelecionadaSeDuplicada(20L));
    }

    private Serie serie(Long id) {
        Editora editora = new Editora();
        editora.setId(3L);
        Serie serie = new Serie();
        serie.setId(id);
        serie.setTitulo("Batman");
        serie.setVolume(1);
        serie.setEditora(editora);
        return serie;
    }
}
