package br.com.hqhub.service;

import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.mockito.ArgumentMatchers.any;

import java.util.Optional;
import java.util.List;
import java.util.Set;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import br.com.hqhub.dto.CadastroEdicaoBrasileiraPaniniDTO;
import br.com.hqhub.dto.EdicaoComicVineRespostaDTO;
import br.com.hqhub.dto.PaginaRespostaDTO;
import br.com.hqhub.dto.VolumeComicVineRespostaDTO;
import br.com.hqhub.entity.Editora;
import br.com.hqhub.entity.Serie;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.EdicaoMapper;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.EditoraRepository;
import br.com.hqhub.repository.PublicacaoRelacionadaRepository;
import br.com.hqhub.repository.PostagemFeedRepository;
import br.com.hqhub.repository.SerieRepository;

class ConteudoOriginalPaniniServiceTest {

    private SerieRepository series;
    private EditoraRepository editoras;
    private IntegracaoExternaService integracoes;
    private PostagemFeedRepository postagens;
    private UsuarioAutenticadoService usuarioAutenticado;
    private ConteudoOriginalPaniniService service;

    @BeforeEach
    void preparar() {
        series = mock(SerieRepository.class);
        editoras = mock(EditoraRepository.class);
        integracoes = mock(IntegracaoExternaService.class);
        postagens = mock(PostagemFeedRepository.class);
        usuarioAutenticado = mock(UsuarioAutenticadoService.class);
        service = new ConteudoOriginalPaniniService(
                mock(EdicaoRepository.class),
                mock(PublicacaoRelacionadaRepository.class),
                mock(ConteudoOriginalPaniniParser.class),
                integracoes,
                editoras,
                series,
                mock(ArmazenamentoImagemService.class),
                mock(EdicaoMapper.class),
                postagens,
                usuarioAutenticado);
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
    void reaproveitaColecaoQueJaExisteComMesmoTituloEditoraEVolume() {
        Editora panini = new Editora();
        panini.setId(7L);
        panini.setNome("Panini");
        Serie existente = new Serie();
        existente.setId(81L);
        existente.setTitulo("Saga dos X-Men, A");
        existente.setVolume(2);
        existente.setTipoSerie(br.com.hqhub.entity.TipoSerie.BRASILEIRA);
        when(editoras.buscarPorNome("Panini")).thenReturn(Optional.of(panini));
        when(series.buscarPorTituloEEditoraEVolume("Saga dos X-Men, A", 7L, 2))
                .thenReturn(Optional.of(existente));

        Serie resultado = service.resolverSerieBrasileiraDestino(
                dto(null, true, "Saga dos X-Men, A", 2), null);

        assertSame(existente, resultado);
    }

    @Test
    void escolheVolumePeloConjuntoCompletoDeNumerosQuandoAnoNaoFoiInformado() {
        VolumeComicVineRespostaDTO incorreto = volume("10", 2015);
        VolumeComicVineRespostaDTO correto = volume("20", 2012);
        when(integracoes.buscarVolumesComicVine("Avengers vs. X-Men", 0, 100))
                .thenReturn(new PaginaRespostaDTO<>(List.of(incorreto, correto), 0, 100, 2, 1));
        when(integracoes.buscarEdicoesVolumeComicVine("10", 0, 100))
                .thenReturn(paginaEdicoes(1, 13));
        when(integracoes.buscarEdicoesVolumeComicVine("20", 0, 100))
                .thenReturn(paginaEdicoes(0, 12));

        VolumeComicVineRespostaDTO resultado = service.resolverVolumeComicVine(
                "Avengers vs. X-Men", null,
                Set.of("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"));

        assertEquals("20", resultado.idExterno());
    }

    @Test
    void infereVolumePelaPrimeiraEdicaoQuandoPontuacaoDoTituloDiverge() {
        when(integracoes.buscarVolumesComicVine("Punisher Red Band", 0, 100))
                .thenReturn(new PaginaRespostaDTO<>(List.of(), 0, 100, 0, 0));
        EdicaoComicVineRespostaDTO primeira = new EdicaoComicVineRespostaDTO(
                "1132008", "1", null, "Punisher: Red Band", "Marvel", "166904",
                "2025-11-01", null, null, null, null, null,
                "https://comicvine.test/issue/1", "https://comicvine.test/issue/1.jpg",
                List.of(), List.of(), List.of());
        when(integracoes.resolverEdicaoComicVineOriginal("Punisher Red Band", "1", null, null))
                .thenReturn(Optional.of(primeira));
        when(integracoes.buscarEdicoesVolumeComicVine("166904", 0, 100))
                .thenReturn(paginaEdicoes(1, 5));

        VolumeComicVineRespostaDTO resultado = service.resolverVolumeComicVine(
                "Punisher Red Band", null,
                new java.util.LinkedHashSet<>(List.of("1", "2", "3", "4", "5")));

        assertEquals("166904", resultado.idExterno());
        assertEquals("Punisher: Red Band", resultado.titulo());
        assertEquals(2025, resultado.anoInicio());
    }

    @Test
    void publicaEdicaoPaniniNoFeedUmaUnicaVez() {
        Usuario usuario = new Usuario();
        usuario.setNome("Colaborador");
        Serie serie = new Serie();
        serie.setTitulo("Justiceiro - Tarja Vermelha");
        Edicao edicao = new Edicao();
        edicao.setId(42536L);
        edicao.setSerie(serie);
        edicao.setNumero("única");
        edicao.setUrlCapa("https://capa.test/justiceiro.jpg");
        when(usuarioAutenticado.obterUsuario()).thenReturn(usuario);
        when(postagens.existePostagemSistemaPorEdicaoCatalogo(42536L)).thenReturn(false);

        service.publicarEdicaoPaniniNoFeed(edicao, new java.util.ArrayList<>());

        verify(postagens).persist(any(br.com.hqhub.entity.PostagemFeed.class));
    }

    private VolumeComicVineRespostaDTO volume(String id, int ano) {
        return new VolumeComicVineRespostaDTO(
                id, "Avengers vs. X-Men", "Marvel", ano, 13, null, null, null);
    }

    private PaginaRespostaDTO<EdicaoComicVineRespostaDTO> paginaEdicoes(int inicio, int fim) {
        List<EdicaoComicVineRespostaDTO> edicoes = java.util.stream.IntStream.rangeClosed(inicio, fim)
                .mapToObj(numero -> new EdicaoComicVineRespostaDTO(
                        String.valueOf(numero), String.valueOf(numero), null, "Avengers vs. X-Men",
                        "Marvel", null, null, null, null, null, null, null, null, null,
                        List.of(), List.of(), List.of()))
                .toList();
        return new PaginaRespostaDTO<>(edicoes, 0, 100, edicoes.size(), 1);
    }

    private CadastroEdicaoBrasileiraPaniniDTO dto(
            Long serieId, boolean criarNovaSerie, String tituloSerie, Integer volumeSerie) {
        return new CadastroEdicaoBrasileiraPaniniDTO(
                "https://panini.com.br/produto", serieId, criarNovaSerie, tituloSerie, volumeSerie,
                "16", null, null, null, null, null, null, null);
    }
}
