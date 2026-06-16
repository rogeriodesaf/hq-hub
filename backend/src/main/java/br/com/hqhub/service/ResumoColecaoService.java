package br.com.hqhub.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import br.com.hqhub.dto.ColecaoResumoDTO;
import br.com.hqhub.dto.EditoraResumoDTO;
import br.com.hqhub.dto.SerieCompletudeDTO;
import br.com.hqhub.dto.SerieResumoDTO;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.ItemColecao;
import br.com.hqhub.entity.Serie;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.ItemColecaoRepository;
import br.com.hqhub.repository.SerieRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class ResumoColecaoService {

    private final ItemColecaoRepository itemColecaoRepository;
    private final SerieRepository serieRepository;
    private final EdicaoRepository edicaoRepository;
    private final UsuarioAutenticadoService usuarioAutenticadoService;

    public ResumoColecaoService(
            ItemColecaoRepository itemColecaoRepository,
            SerieRepository serieRepository,
            EdicaoRepository edicaoRepository,
            UsuarioAutenticadoService usuarioAutenticadoService) {
        this.itemColecaoRepository = itemColecaoRepository;
        this.serieRepository = serieRepository;
        this.edicaoRepository = edicaoRepository;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
    }

    @Transactional
    public ColecaoResumoDTO gerarResumo() {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        List<ItemColecao> itens = itemColecaoRepository.list("usuario.id", usuario.getId());

        Set<Long> idsSeries = new HashSet<>();
        Set<Long> idsEditoras = new HashSet<>();
        BigDecimal valorTotalPago = BigDecimal.ZERO;

        for (ItemColecao item : itens) {
            Serie serie = item.getEdicao().getSerie();
            idsSeries.add(serie.getId());
            idsEditoras.add(serie.getEditora().getId());

            if (item.getPrecoPago() != null) {
                valorTotalPago = valorTotalPago.add(item.getPrecoPago());
            }
        }

        return new ColecaoResumoDTO(
                itens.size(),
                idsSeries.size(),
                idsEditoras.size(),
                valorTotalPago);
    }

    @Transactional
    public SerieCompletudeDTO calcularCompletudePorSerie(Long serieId) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        Serie serie = serieRepository.findByIdOptional(serieId)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Série não encontrada."));

        List<Edicao> edicoes = edicaoRepository.list("serie.id", serieId);
        Set<Long> idsPossuidas = new HashSet<>(
                itemColecaoRepository.listarIdsEdicoesPorUsuarioESerie(usuario.getId(), serieId));

        long totalEdicoes = edicoes.size();
        long totalPossuidas = edicoes.stream()
                .filter(edicao -> idsPossuidas.contains(edicao.getId()))
                .count();
        long totalFaltantes = totalEdicoes - totalPossuidas;

        BigDecimal percentualCompleto = totalEdicoes == 0
                ? BigDecimal.ZERO
                : BigDecimal.valueOf(totalPossuidas)
                        .multiply(BigDecimal.valueOf(100))
                        .divide(BigDecimal.valueOf(totalEdicoes), 2, RoundingMode.HALF_UP);

        return new SerieCompletudeDTO(
                new SerieResumoDTO(
                        serie.getId(),
                        serie.getTitulo(),
                        new EditoraResumoDTO(serie.getEditora().getId(), serie.getEditora().getNome())),
                totalEdicoes,
                totalPossuidas,
                totalFaltantes,
                percentualCompleto);
    }
}
