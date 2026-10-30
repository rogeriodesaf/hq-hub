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
    private EdicaoRepository edicoes;
    private EditoraRepository editoras;
    private IntegracaoExternaService integracoes;
    private PostagemFeedRepository postagens;
    private UsuarioAutenticadoService usuarioAutenticado;
    private ConteudoOriginalPaniniService service;

    @BeforeEach
    void preparar() {
        series = mock(SerieRepository.class);
        edicoes = mock(EdicaoRepository.class);
        editoras = mock(EditoraRepository.class);
        integracoes = mock(IntegracaoExternaService.class);
        postagens = mock(PostagemFeedRepository.class);
        usuarioAutenticado = mock(UsuarioAutenticadoService.class);
        service = new ConteudoOriginalPaniniService(
                edicoes,
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
    void escolheVolumePelosNumerosQuandoAnoDaEdicaoDivergeDoInicioDoVolume() {
        VolumeComicVineRespostaDTO especial450 = new VolumeComicVineRespostaDTO(
                "30", "Doctor Strange", "Marvel", 2025, 1, null, null, null);
        VolumeComicVineRespostaDTO serieAtual = new VolumeComicVineRespostaDTO(
                "40", "Doctor Strange", "Marvel", 2025, 7, null, null, null);
        when(integracoes.buscarVolumesComicVine("Doctor Strange", 0, 100))
                .thenReturn(new PaginaRespostaDTO<>(List.of(especial450, serieAtual), 0, 100, 2, 1));
        when(integracoes.buscarEdicoesVolumeComicVine("30", 0, 100))
                .thenReturn(paginaEdicoesDoctorStrange(450, 450, "30"));
        when(integracoes.buscarEdicoesVolumeComicVine("40", 0, 100))
                .thenReturn(paginaEdicoesDoctorStrange(1, 7, "40"));

        VolumeComicVineRespostaDTO resultado = service.resolverVolumeComicVine(
                "Doctor Strange", 2026, Set.of("1", "2", "3", "4", "5"));

        assertEquals("40", resultado.idExterno());
    }

    @Test
    void resolveEdicaoDiretamenteQuandoComicVineNaoOfereceVolumeUnico() {
        when(integracoes.buscarVolumesComicVine("Doctor Strange", 0, 100))
                .thenReturn(new PaginaRespostaDTO<>(List.of(), 0, 100, 0, 0));
        EdicaoComicVineRespostaDTO edicao = new EdicaoComicVineRespostaDTO(
                "1146680", "1", null, "Doctor Strange", "Marvel", "170000",
                "2026-02-01", "2025-12-03", null, null, null, null,
                "https://comicvine.test/doctor-strange-1",
                "https://comicvine.test/doctor-strange-1.jpg",
                List.of(), List.of(), List.of());
        when(integracoes.resolverEdicaoComicVineOriginal("Doctor Strange", "1", 2026, null))
                .thenReturn(Optional.of(edicao));
        when(integracoes.buscarDetalheVolumeComicVine("170000"))
                .thenReturn(new VolumeComicVineRespostaDTO(
                        "170000", "Doctor Strange", "Marvel", 2025, 10,
                        null, "https://comicvine.test/doctor-strange", null));

        var resultado = service.resolverEdicaoComicVine(new br.com.hqhub.dto.CadastroEdicaoOriginalPaniniDTO(
                "https://panini.com.br/produto", "Doctor Strange", 2026, "1"));

        assertEquals("1146680", resultado.edicao().idExterno());
        assertEquals("170000", resultado.volume().idExterno());
    }

    @Test
    void converteNumeroZeroDeUltimateSpiderManParaEdicaoMeioDaComicVine() {
        VolumeComicVineRespostaDTO volume = new VolumeComicVineRespostaDTO(
                "7257", "Ultimate Spider-Man", "Marvel", 2000, 134, null, null, null);
        EdicaoComicVineRespostaDTO edicaoMeio = new EdicaoComicVineRespostaDTO(
                "300000", "½", null, "Ultimate Spider-Man", "Marvel", "7257",
                "2002-01-01", null, null, null, null, null,
                "https://comicvine.test/ultimate-spider-man-half",
                "https://comicvine.test/ultimate-spider-man-half.jpg",
                List.of(), List.of(), List.of());
        when(integracoes.buscarVolumesComicVine("Ultimate Spider-Man", 0, 100))
                .thenReturn(new PaginaRespostaDTO<>(List.of(volume), 0, 100, 1, 1));
        when(integracoes.buscarEdicoesVolumeComicVine("7257", 0, 100))
                .thenReturn(new PaginaRespostaDTO<>(List.of(edicaoMeio), 0, 100, 1, 1));
        when(integracoes.buscarDetalheEdicaoComicVine("300000")).thenReturn(edicaoMeio);

        var resultado = service.resolverEdicaoComicVine(new br.com.hqhub.dto.CadastroEdicaoOriginalPaniniDTO(
                "https://panini.com.br/produto", "Ultimate Spider-Man", 2000, "0"));

        assertEquals("300000", resultado.edicao().idExterno());
        assertEquals("½", resultado.edicao().numero());
    }

    @Test
    void preencheCapaComicVineNaEdicaoExistenteSemTrocarSuaIdentidade() {
        Editora marvel = new Editora();
        marvel.setNome("Marvel Comics");
        Serie serie = new Serie();
        serie.setTitulo("Ultimate X-Men, The (2001)");
        serie.setAnoInicio(2001);
        serie.setTipoSerie(br.com.hqhub.entity.TipoSerie.ESTRANGEIRA);
        serie.setEditora(marvel);
        Edicao existente = new Edicao();
        existente.setId(42570L);
        existente.setSerie(serie);
        existente.setNumero("1");
        existente.setFonteExterna("GUIA_DOS_QUADRINHOS");
        existente.setIdExterno("guia-ultimate-x-men-1");
        when(edicoes.findByIdOptional(42570L)).thenReturn(Optional.of(existente));

        EdicaoComicVineRespostaDTO externa = new EdicaoComicVineRespostaDTO(
                "53564", "1", "The Tomorrow People, Part 1", "Ultimate X-Men", "Marvel", "7258",
                "2001-02-01", null, null, "Original", "Português", null,
                "https://comicvine.test/ultimate-x-men-1",
                "https://comicvine.test/ultimate-x-men-1.jpg",
                List.of(), List.of(), List.of());
        VolumeComicVineRespostaDTO volume = new VolumeComicVineRespostaDTO(
                "7258", "Ultimate X-Men", "Marvel", 2001, 100,
                null, "https://comicvine.test/ultimate-x-men", null);

        Edicao resultado = service.localizarOuCriarEdicaoComicVine(
                externa, volume,
                new br.com.hqhub.dto.CadastroEdicaoOriginalPaniniDTO(
                        "https://panini.com.br/produto", "The Ultimate X-Men", 2000, "1"),
                42570L);

        assertSame(existente, resultado);
        assertEquals("https://comicvine.test/ultimate-x-men-1.jpg", resultado.getUrlCapa());
        assertEquals("53564", resultado.getIdComicVine());
        assertEquals("GUIA_DOS_QUADRINHOS", resultado.getFonteExterna());
        assertEquals("guia-ultimate-x-men-1", resultado.getIdExterno());
    }

    @Test
    void rejeitaCapaQuandoEditoraDaComicVineDivergeDoCatalogo() {
        Editora dc = new Editora();
        dc.setNome("DC Comics");
        Serie serie = new Serie();
        serie.setTitulo("Ultimate X-Men");
        serie.setAnoInicio(2001);
        serie.setTipoSerie(br.com.hqhub.entity.TipoSerie.ESTRANGEIRA);
        serie.setEditora(dc);
        Edicao existente = new Edicao();
        existente.setId(42570L);
        existente.setSerie(serie);
        existente.setNumero("1");
        when(edicoes.findByIdOptional(42570L)).thenReturn(Optional.of(existente));
        EdicaoComicVineRespostaDTO externa = new EdicaoComicVineRespostaDTO(
                "53564", "1", null, "Ultimate X-Men", "Marvel", "7258",
                null, null, null, null, null, null, null, "https://comicvine.test/capa.jpg",
                List.of(), List.of(), List.of());
        VolumeComicVineRespostaDTO volume = new VolumeComicVineRespostaDTO(
                "7258", "Ultimate X-Men", "Marvel", 2001, 100, null, null, null);

        assertThrows(RegraNegocioException.class, () -> service.localizarOuCriarEdicaoComicVine(
                externa, volume,
                new br.com.hqhub.dto.CadastroEdicaoOriginalPaniniDTO(
                        "https://panini.com.br/produto", "Ultimate X-Men", 2000, "1"),
                42570L));
    }

    @Test
    void cadastraEdicaoNaColecaoExistenteMesmoQuandoTituloDoGuiaIncluiAno() {
        Editora marvel = new Editora();
        marvel.setId(7L);
        marvel.setNome("Marvel Comics");
        Serie longshot = new Serie();
        longshot.setId(81L);
        longshot.setTitulo("Longshot (1985)");
        longshot.setAnoInicio(1985);
        longshot.setTipoSerie(br.com.hqhub.entity.TipoSerie.ESTRANGEIRA);
        longshot.setEditora(marvel);
        when(edicoes.buscarPorOrigemExterna("COMICVINE", "65000")).thenReturn(Optional.empty());
        when(editoras.buscarPorNome("Marvel")).thenReturn(Optional.of(marvel));
        when(series.buscarTodasPorTituloEEditoraEVolume("Longshot (1985)", 7L, null))
                .thenReturn(List.of(longshot));
        when(edicoes.buscarPorNumeroESerie("1", 81L)).thenReturn(Optional.empty());
        EdicaoComicVineRespostaDTO externa = new EdicaoComicVineRespostaDTO(
                "65000", "1", null, "Longshot", "Marvel", "9000",
                "1985-09-01", null, null, null, null, null,
                "https://comicvine.test/longshot-1", "https://comicvine.test/longshot-1.jpg",
                List.of(), List.of(), List.of());
        VolumeComicVineRespostaDTO volume = new VolumeComicVineRespostaDTO(
                "9000", "Longshot", "Marvel", 1985, 6, null, null, null);

        Edicao resultado = service.localizarOuCriarEdicaoComicVine(
                externa, volume,
                new br.com.hqhub.dto.CadastroEdicaoOriginalPaniniDTO(
                        "https://panini.com.br/produto", "Longshot", 1985, "1"),
                null);

        assertSame(longshot, resultado.getSerie());
        verify(series, never()).persist(any(Serie.class));
        verify(edicoes).persist(resultado);
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
        when(integracoes.buscarDetalheVolumeComicVine("166904"))
                .thenReturn(new VolumeComicVineRespostaDTO(
                        "166904", "Punisher: Red Band", "Marvel", 2025, 5,
                        null, "https://comicvine.test/volume/166904", null));
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

    private PaginaRespostaDTO<EdicaoComicVineRespostaDTO> paginaEdicoesDoctorStrange(
            int inicio, int fim, String idVolume) {
        List<EdicaoComicVineRespostaDTO> edicoes = java.util.stream.IntStream.rangeClosed(inicio, fim)
                .mapToObj(numero -> new EdicaoComicVineRespostaDTO(
                        String.valueOf(numero), String.valueOf(numero), null, "Doctor Strange",
                        "Marvel", idVolume, null, null, null, null, null, null, null, null,
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
