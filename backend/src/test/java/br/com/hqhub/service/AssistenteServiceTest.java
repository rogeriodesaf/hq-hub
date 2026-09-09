package br.com.hqhub.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Map;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import br.com.hqhub.dto.RespostaAssistenteDTO;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.Editora;
import br.com.hqhub.entity.Serie;
import br.com.hqhub.repository.CriadorRepository;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.SerieRepository;

class AssistenteServiceTest {

    private EdicaoRepository edicoes;
    private AssistenteService assistente;

    @BeforeEach
    void preparar() {
        edicoes = mock(EdicaoRepository.class);
        assistente = new AssistenteService(
                mock(ResumoColecaoService.class),
                mock(FaltanteService.class),
                mock(CompraPlanejadaService.class),
                mock(CreditoEdicaoService.class),
                mock(RelacionamentoSerieService.class),
                mock(ConhecimentoEditorialService.class),
                mock(SerieRepository.class),
                edicoes,
                mock(CriadorRepository.class));
    }

    @Test
    void contaTodasAsEdicoesDoHeroiEDistribuiPorTitulo() {
        Serie batman = serie(1L, "Batman", "Panini", 1);
        Serie lendas = serie(2L, "Lendas do Cavaleiro das Trevas: Batman", "Panini", 1);
        when(edicoes.buscarTodosComBusca(null, "Batman"))
                .thenReturn(List.of(edicao(10L, batman), edicao(11L, batman), edicao(12L, lendas)));

        RespostaAssistenteDTO resposta = assistente.responder(
                "Quantas edições do Batman existem cadastradas no HQ-HUB?");

        assertEquals("BANCO_LOCAL", resposta.origem());
        assertTrue(resposta.resposta().contains("3 edições"));
        assertTrue(resposta.resposta().contains("2 títulos"));
        Map<?, ?> dados = (Map<?, ?>) resposta.dados();
        assertEquals(3, dados.get("totalEdicoes"));
        assertEquals(2, dados.get("totalTitulos"));
        verify(edicoes).buscarTodosComBusca(null, "Batman");
    }

    @Test
    void entendeTituloEditoraEVolumeNaPergunta() {
        Serie serie = serie(7L, "Marvel Knights: 4", "Panini", 1);
        when(edicoes.buscarTodosComBusca(null, "Marvel Knights 4 Panini V1"))
                .thenReturn(List.of(edicao(20L, serie), edicao(21L, serie)));

        RespostaAssistenteDTO resposta = assistente.responder(
                "Quantas edições de Marvel Knights: 4 Panini V1 existem?");

        assertEquals("BANCO_LOCAL", resposta.origem());
        assertTrue(resposta.resposta().contains("Marvel Knights: 4 V1 tem 2 edições"));
        verify(edicoes).buscarTodosComBusca(null, "Marvel Knights 4 Panini V1");
    }

    @Test
    void priorizaContagemQuandoAPerguntaUsaQuantosVolumes() {
        Serie serie = serie(1L, "Batman", "Panini", 1);
        when(edicoes.buscarTodosComBusca(null, "Batman")).thenReturn(List.of(edicao(1L, serie)));

        RespostaAssistenteDTO resposta = assistente.responder("Quantos volumes de Batman existem?");

        assertEquals("BANCO_LOCAL", resposta.origem());
        assertTrue(resposta.resposta().contains("tem 1 "), resposta.resposta());
        verify(edicoes).buscarTodosComBusca(null, "Batman");
    }

    private Serie serie(Long id, String titulo, String nomeEditora, Integer volume) {
        Editora editora = new Editora();
        editora.setId(id);
        editora.setNome(nomeEditora);
        Serie serie = new Serie();
        serie.setId(id);
        serie.setTitulo(titulo);
        serie.setVolume(volume);
        serie.setEditora(editora);
        return serie;
    }

    private Edicao edicao(Long id, Serie serie) {
        Edicao edicao = new Edicao();
        edicao.setId(id);
        edicao.setSerie(serie);
        return edicao;
    }
}
