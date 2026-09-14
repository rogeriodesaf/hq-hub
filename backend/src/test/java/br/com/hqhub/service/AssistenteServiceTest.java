package br.com.hqhub.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import br.com.hqhub.dto.CriadorRespostaDTO;
import br.com.hqhub.dto.CreditoEdicaoRespostaDTO;
import br.com.hqhub.dto.RespostaAssistenteDTO;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.Editora;
import br.com.hqhub.entity.PapelCriador;
import br.com.hqhub.entity.Serie;
import br.com.hqhub.entity.TipoSerie;
import br.com.hqhub.repository.CriadorRepository;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.SerieRepository;

class AssistenteServiceTest {

    private EdicaoRepository edicoes;
    private SerieRepository series;
    private CreditoEdicaoService creditos;
    private AssistenteService assistente;

    @BeforeEach
    void preparar() {
        edicoes = mock(EdicaoRepository.class);
        series = mock(SerieRepository.class);
        creditos = mock(CreditoEdicaoService.class);
        assistente = new AssistenteService(
                mock(ResumoColecaoService.class),
                mock(FaltanteService.class),
                mock(CompraPlanejadaService.class),
                creditos,
                mock(RelacionamentoSerieService.class),
                mock(ConhecimentoEditorialService.class),
                series,
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

    @Test
    void respondeTotaisDoCatalogoNacional() {
        when(series.contarComBusca(null, null, TipoSerie.BRASILEIRA)).thenReturn(125L);
        when(edicoes.contarComBusca(null, null, TipoSerie.BRASILEIRA)).thenReturn(980L);

        RespostaAssistenteDTO resposta = assistente.responder("Quantos títulos existem no catálogo?");

        assertEquals("BANCO_LOCAL", resposta.origem());
        assertTrue(resposta.resposta().contains("125 título(s)"));
        assertTrue(resposta.resposta().contains("980 edição(ões)"));
        Map<?, ?> dados = (Map<?, ?>) resposta.dados();
        assertEquals(125L, dados.get("totalTitulos"));
        assertEquals(980L, dados.get("totalEdicoes"));
    }

    @Test
    void respondeAnoDaSerieComEditoraEVolume() {
        Serie batman = serie(1L, "Batman", "Panini", 1);
        batman.setAnoInicio(2002);
        batman.setAnoFim(2011);
        when(series.listAll()).thenReturn(List.of(batman));

        RespostaAssistenteDTO resposta = assistente.responder(
                "Em que ano Batman Panini V1 foi lançado?");

        assertEquals("BANCO_LOCAL", resposta.origem());
        assertTrue(resposta.resposta().contains("entre 2002 e 2011"), resposta.resposta());
    }

    @Test
    void respondeAutorConsultandoOsCreditosDaSerie() {
        Serie batman = serie(1L, "Batman", "Panini", 1);
        CriadorRespostaDTO criador = new CriadorRespostaDTO(
                9L, "Scott Snyder", null, null, null, null, LocalDateTime.now(), LocalDateTime.now());
        CreditoEdicaoRespostaDTO credito = new CreditoEdicaoRespostaDTO(
                15L, criador, null, PapelCriador.ROTEIRO, null);
        when(series.listAll()).thenReturn(List.of(batman));
        when(creditos.listarPorSerie(1L)).thenReturn(List.of(credito));

        RespostaAssistenteDTO resposta = assistente.responder("Quem escreveu Batman Panini V1?");

        assertEquals("BANCO_LOCAL", resposta.origem());
        assertTrue(resposta.resposta().contains("roteiro: Scott Snyder"), resposta.resposta());
        verify(creditos).listarPorSerie(1L);
    }

    @Test
    void informaQuandoCreditoAindaNaoFoiCadastrado() {
        Serie batman = serie(1L, "Batman", "Panini", 1);
        Edicao primeira = edicao(10L, batman);
        primeira.setNumero("1");
        when(series.listAll()).thenReturn(List.of(batman));
        when(edicoes.buscarPorNumeroESerie("1", 1L)).thenReturn(java.util.Optional.of(primeira));
        when(creditos.listarPorEdicao(10L)).thenReturn(List.of());

        RespostaAssistenteDTO resposta = assistente.responder("Quem desenhou Batman edição nº 1?");

        assertEquals("BANCO_LOCAL", resposta.origem());
        assertTrue(resposta.resposta().contains("ainda não possui crédito"), resposta.resposta());
        verify(creditos).listarPorEdicao(10L);
    }

    @Test
    void respondeMetadadosDaEdicaoSemInventarCamposAusentes() {
        Serie batman = serie(1L, "Batman", "Panini", 1);
        Edicao primeira = edicao(10L, batman);
        primeira.setNumero("1");
        primeira.setTitulo("A Corte das Corujas");
        primeira.setQuantidadePaginas(148);
        when(series.listAll()).thenReturn(List.of(batman));
        when(edicoes.buscarPorNumeroESerie("1", 1L)).thenReturn(java.util.Optional.of(primeira));

        RespostaAssistenteDTO resposta = assistente.responder("Quantas páginas tem Batman edição nº 1?");

        assertEquals("BANCO_LOCAL", resposta.origem());
        assertTrue(resposta.resposta().contains("148 páginas"), resposta.resposta());
        assertTrue(resposta.resposta().contains("preço de capa não cadastrado"), resposta.resposta());
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
