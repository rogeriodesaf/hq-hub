package br.com.hqhub.service;

import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import br.com.hqhub.dto.CadastroEdicaoBrasileiraPaniniDTO;
import br.com.hqhub.entity.Editora;
import br.com.hqhub.entity.Serie;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.EdicaoMapper;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.EditoraRepository;
import br.com.hqhub.repository.PublicacaoRelacionadaRepository;
import br.com.hqhub.repository.SerieRepository;

class ConteudoOriginalPaniniServiceTest {

    private SerieRepository series;
    private EditoraRepository editoras;
    private ConteudoOriginalPaniniService service;

    @BeforeEach
    void preparar() {
        series = mock(SerieRepository.class);
        editoras = mock(EditoraRepository.class);
        service = new ConteudoOriginalPaniniService(
                mock(EdicaoRepository.class),
                mock(PublicacaoRelacionadaRepository.class),
                mock(ConteudoOriginalPaniniParser.class),
                mock(IntegracaoExternaService.class),
                editoras,
                series,
                mock(ArmazenamentoImagemService.class),
                mock(EdicaoMapper.class));
    }

    @Test
    void usaColecaoExistentePeloIdSemCriarOutra() {
        Serie existente = new Serie();
        existente.setId(42L);
        existente.setTitulo("Saga dos X-Men, A");
        existente.setVolume(2);
        when(series.findByIdOptional(42L)).thenReturn(Optional.of(existente));

        Serie resultado = service.resolverSerieBrasileiraDestino(dto(42L, false, null, null), null);

        assertSame(existente, resultado);
        verify(editoras, never()).buscarPorNome("Panini");
    }

    @Test
    void exigeSelecaoOuConfirmacaoExplicitaDeNovaColecao() {
        assertThrows(RegraNegocioException.class,
                () -> service.resolverSerieBrasileiraDestino(dto(null, false, null, null), null));
    }

    @Test
    void impedeCriarColecaoQueJaExisteComMesmoTituloEditoraEVolume() {
        Editora panini = new Editora();
        panini.setId(7L);
        panini.setNome("Panini");
        when(editoras.buscarPorNome("Panini")).thenReturn(Optional.of(panini));
        when(series.buscarPorTituloEEditoraEVolume("Saga dos X-Men, A", 7L, 2))
                .thenReturn(Optional.of(new Serie()));

        assertThrows(RegraNegocioException.class,
                () -> service.resolverSerieBrasileiraDestino(
                        dto(null, true, "Saga dos X-Men, A", 2), null));
    }

    private CadastroEdicaoBrasileiraPaniniDTO dto(
            Long serieId, boolean criarNovaSerie, String tituloSerie, Integer volumeSerie) {
        return new CadastroEdicaoBrasileiraPaniniDTO(
                "https://panini.com.br/produto", serieId, criarNovaSerie, tituloSerie, volumeSerie,
                "16", null, null, null, null, null, null, null);
    }
}
