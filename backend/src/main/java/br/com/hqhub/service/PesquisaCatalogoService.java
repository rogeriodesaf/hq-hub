package br.com.hqhub.service;

import java.util.List;

import br.com.hqhub.dto.FonteResultadoCatalogo;
import br.com.hqhub.dto.PaginaRespostaDTO;
import br.com.hqhub.dto.ResultadoPesquisaCatalogoDTO;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.TipoSerie;
import br.com.hqhub.repository.EdicaoRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class PesquisaCatalogoService {

    private static final int TAMANHO_MAXIMO = 100;

    private final EdicaoRepository edicaoRepository;

    public PesquisaCatalogoService(EdicaoRepository edicaoRepository) {
        this.edicaoRepository = edicaoRepository;
    }

    @Transactional
    public PaginaRespostaDTO<ResultadoPesquisaCatalogoDTO> pesquisarCatalogo(String termo, Integer pagina, Integer tamanho) {
        if (termo == null || termo.isBlank()) {
            return new PaginaRespostaDTO<>(List.of(), 0, tratarTamanho(tamanho), 0, 0);
        }

        int paginaTratada = tratarPagina(pagina);
        int tamanhoTratado = tratarTamanho(tamanho);
        long totalInternos = edicaoRepository.contarComBusca(null, termo, TipoSerie.BRASILEIRA);
        int totalPaginasInternas = (int) Math.ceil((double) totalInternos / tamanhoTratado);
        List<ResultadoPesquisaCatalogoDTO> internos = edicaoRepository
                .buscarPaginado(null, termo, paginaTratada, tamanhoTratado, TipoSerie.BRASILEIRA)
                .stream()
                .map(this::paraResultadoInterno)
                .toList();

        return new PaginaRespostaDTO<>(
                internos,
                paginaTratada,
                tamanhoTratado,
                totalInternos,
                totalPaginasInternas);
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

    private int tratarPagina(Integer pagina) {
        return pagina == null || pagina < 0 ? 0 : pagina;
    }

    private int tratarTamanho(Integer tamanho) {
        if (tamanho == null || tamanho <= 0) {
            return 20;
        }

        return Math.min(tamanho, TAMANHO_MAXIMO);
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
