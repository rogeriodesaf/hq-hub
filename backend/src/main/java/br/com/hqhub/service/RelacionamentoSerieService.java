package br.com.hqhub.service;

import java.util.Comparator;
import java.util.List;

import br.com.hqhub.dto.CadastroRelacionamentoSerieDTO;
import br.com.hqhub.dto.RelacionamentoSerieRespostaDTO;
import br.com.hqhub.entity.RelacionamentoSerie;
import br.com.hqhub.entity.Serie;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.RelacionamentoSerieMapper;
import br.com.hqhub.repository.RelacionamentoSerieRepository;
import br.com.hqhub.repository.SerieRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class RelacionamentoSerieService {

    private final RelacionamentoSerieRepository relacionamentoSerieRepository;
    private final SerieRepository serieRepository;
    private final RelacionamentoSerieMapper relacionamentoSerieMapper;

    public RelacionamentoSerieService(
            RelacionamentoSerieRepository relacionamentoSerieRepository,
            SerieRepository serieRepository,
            RelacionamentoSerieMapper relacionamentoSerieMapper) {
        this.relacionamentoSerieRepository = relacionamentoSerieRepository;
        this.serieRepository = serieRepository;
        this.relacionamentoSerieMapper = relacionamentoSerieMapper;
    }

    @Transactional
    public RelacionamentoSerieRespostaDTO cadastrar(CadastroRelacionamentoSerieDTO dto) {
        if (dto.serieOrigemId().equals(dto.serieDestinoId())) {
            throw new RegraNegocioException("Série de origem e série de destino devem ser diferentes.");
        }

        Serie origem = buscarSeriePorId(dto.serieOrigemId());
        Serie destino = buscarSeriePorId(dto.serieDestinoId());

        if (relacionamentoSerieRepository.existePorOrigemDestinoTipo(dto.serieOrigemId(), dto.serieDestinoId(), dto.tipo())) {
            throw new RegraNegocioException("Este relacionamento entre séries já está cadastrado.");
        }

        RelacionamentoSerie relacionamento = relacionamentoSerieMapper.paraEntidade(dto, origem, destino);
        relacionamentoSerieRepository.persist(relacionamento);

        return relacionamentoSerieMapper.paraResposta(relacionamento);
    }

    @Transactional
    public List<RelacionamentoSerieRespostaDTO> listarPorSerie(Long serieId) {
        buscarSeriePorId(serieId);

        return relacionamentoSerieRepository
                .list("serieOrigem.id = ?1 or serieDestino.id = ?1", serieId)
                .stream()
                .sorted(Comparator.comparing(RelacionamentoSerie::getTipo))
                .map(relacionamentoSerieMapper::paraResposta)
                .toList();
    }

    @Transactional
    public void remover(Long id) {
        RelacionamentoSerie relacionamento = relacionamentoSerieRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Relacionamento entre séries não encontrado."));
        relacionamentoSerieRepository.delete(relacionamento);
    }

    private Serie buscarSeriePorId(Long id) {
        return serieRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Série não encontrada."));
    }
}
