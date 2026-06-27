package br.com.hqhub.service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;

import br.com.hqhub.dto.EdicaoComicVineRespostaDTO;
import br.com.hqhub.dto.FonteResultadoCatalogo;
import br.com.hqhub.dto.PaginaRespostaDTO;
import br.com.hqhub.dto.ResultadoPesquisaCatalogoDTO;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.repository.EdicaoRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class PesquisaCatalogoService {

    private static final String FONTE_COMIC_VINE = "COMICVINE";
    private static final int LIMITE_INTERNO = 200;
    private static final int TAMANHO_MAXIMO = 100;

    private final EdicaoRepository edicaoRepository;
    private final IntegracaoExternaService integracaoExternaService;

    public PesquisaCatalogoService(
            EdicaoRepository edicaoRepository,
            IntegracaoExternaService integracaoExternaService) {
        this.edicaoRepository = edicaoRepository;
        this.integracaoExternaService = integracaoExternaService;
    }

    @Transactional
    public PaginaRespostaDTO<ResultadoPesquisaCatalogoDTO> pesquisarCatalogo(String termo, Integer pagina, Integer tamanho) {
        if (termo == null || termo.isBlank()) {
            return new PaginaRespostaDTO<>(List.of(), 0, tratarTamanho(tamanho), 0, 0);
        }

        int paginaTratada = tratarPagina(pagina);
        int tamanhoTratado = tratarTamanho(tamanho);
        List<ResultadoPesquisaCatalogoDTO> resultados = new ArrayList<>();
        Set<String> chaves = new LinkedHashSet<>();
        List<Edicao> edicoesInternas = edicaoRepository.buscarPaginado(null, termo, 0, LIMITE_INTERNO);

        edicoesInternas.stream()
                .map(this::paraResultadoInterno)
                .forEach(resultado -> adicionarResultado(resultados, chaves, resultado));

        PaginaRespostaDTO<EdicaoComicVineRespostaDTO> externos = buscarExternos(termo, paginaTratada, tamanhoTratado);
        externos.itens().stream()
                .map(this::paraResultadoExterno)
                .filter(resultado -> !jaExisteNoCatalogoInterno(resultado, edicoesInternas))
                .forEach(resultado -> adicionarResultado(resultados, chaves, resultado));

        return new PaginaRespostaDTO<>(
                resultados,
                paginaTratada,
                tamanhoTratado,
                externos.totalItens(),
                externos.totalPaginas());
    }

    private PaginaRespostaDTO<EdicaoComicVineRespostaDTO> buscarExternos(String termo, int pagina, int tamanho) {
        try {
            return integracaoExternaService.buscarEdicoesComicVinePorTermo(termo, pagina, tamanho);
        } catch (RegraNegocioException e) {
            return new PaginaRespostaDTO<>(List.of(), pagina, tamanho, 0, 0);
        }
    }

    private ResultadoPesquisaCatalogoDTO paraResultadoInterno(Edicao edicao) {
        return new ResultadoPesquisaCatalogoDTO(
                edicao.getId(),
                primeiroValor(edicao.getIdComicVine(), edicao.getIdExterno()),
                FonteResultadoCatalogo.HQ_HUB,
                primeiroValor(edicao.getTitulo(), edicao.getSerie().getTitulo()),
                edicao.getNumero(),
                primeiroValor(edicao.getNomeVolume(), edicao.getSerie().getTitulo()),
                edicao.getSerie().getVolume(),
                edicao.getUrlCapa(),
                primeiroValor(edicao.getDataPublicacao(), edicao.getDataCobertura(), edicao.getDataDisponibilidadeLoja()),
                true,
                primeiroValor(edicao.getUrlComicVine(), edicao.getUrlOrigem()));
    }

    private ResultadoPesquisaCatalogoDTO paraResultadoExterno(EdicaoComicVineRespostaDTO edicao) {
        return new ResultadoPesquisaCatalogoDTO(
                null,
                edicao.idExterno(),
                FonteResultadoCatalogo.COMIC_VINE,
                primeiroValor(edicao.titulo(), edicao.nomeVolume()),
                edicao.numero(),
                edicao.nomeVolume(),
                null,
                edicao.urlImagem(),
                primeiroValor(parseData(edicao.dataVenda()), parseData(edicao.dataCapa())),
                false,
                edicao.urlOrigem());
    }

    private boolean jaExisteNoCatalogoInterno(ResultadoPesquisaCatalogoDTO externo, List<Edicao> internas) {
        return internas.stream().anyMatch(interna -> mesmaOrigemComicVine(externo, interna) || mesmoTituloNumeroVolume(externo, interna));
    }

    private boolean mesmaOrigemComicVine(ResultadoPesquisaCatalogoDTO externo, Edicao interna) {
        if (externo.idExterno() == null || externo.idExterno().isBlank()) {
            return false;
        }

        return externo.idExterno().equals(interna.getIdComicVine())
                || externo.idExterno().equals(interna.getIdExterno())
                || (FONTE_COMIC_VINE.equalsIgnoreCase(interna.getFonteExterna())
                        && externo.idExterno().equals(interna.getIdExterno()));
    }

    private boolean mesmoTituloNumeroVolume(ResultadoPesquisaCatalogoDTO externo, Edicao interna) {
        String numeroInterno = normalizar(interna.getNumero());
        String numeroExterno = normalizar(externo.numero());
        String volumeInterno = normalizar(primeiroValor(interna.getNomeVolume(), interna.getSerie().getTitulo()));
        String volumeExterno = normalizar(externo.nomeVolume());
        String tituloInterno = normalizar(primeiroValor(interna.getTitulo(), interna.getSerie().getTitulo()));
        String tituloExterno = normalizar(externo.titulo());

        return !numeroInterno.isBlank()
                && numeroInterno.equals(numeroExterno)
                && (!volumeInterno.isBlank() && volumeInterno.equals(volumeExterno)
                        || !tituloInterno.isBlank() && tituloInterno.equals(tituloExterno));
    }

    private void adicionarResultado(
            List<ResultadoPesquisaCatalogoDTO> resultados,
            Set<String> chaves,
            ResultadoPesquisaCatalogoDTO resultado) {
        String chave = chaveResultado(resultado);
        if (chaves.add(chave)) {
            resultados.add(resultado);
        }
    }

    private String chaveResultado(ResultadoPesquisaCatalogoDTO resultado) {
        if (resultado.fonte() == FonteResultadoCatalogo.HQ_HUB && resultado.id() != null) {
            return "interno:" + resultado.id();
        }

        if (resultado.idExterno() != null && !resultado.idExterno().isBlank()) {
            return "comicvine:" + resultado.idExterno();
        }

        return "aproximado:" + normalizar(resultado.nomeVolume()) + ":" + normalizar(resultado.numero()) + ":"
                + normalizar(resultado.titulo());
    }

    private String normalizar(String valor) {
        return valor == null ? "" : valor.trim().toLowerCase(Locale.ROOT);
    }

    private int tratarPagina(Integer pagina) {
        return pagina == null || pagina < 0 ? 0 : pagina;
    }

    private int tratarTamanho(Integer tamanho) {
        if (tamanho == null || tamanho <= 0) {
            return 20;
        }

        return Math.min(tamanho, TAMANHO_MAXIMO);
    }

    private LocalDate parseData(String valor) {
        if (valor == null || valor.isBlank()) {
            return null;
        }

        try {
            return LocalDate.parse(valor);
        } catch (RuntimeException e) {
            return null;
        }
    }

    @SafeVarargs
    private final <T> T primeiroValor(T... valores) {
        for (T valor : valores) {
            if (valor instanceof String texto && !texto.isBlank()) {
                return valor;
            }

            if (valor != null && !(valor instanceof String)) {
                return valor;
            }
        }

        return null;
    }
}
