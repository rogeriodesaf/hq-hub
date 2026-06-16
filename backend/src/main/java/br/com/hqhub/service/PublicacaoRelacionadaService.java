package br.com.hqhub.service;

import java.util.Comparator;
import java.util.List;

import br.com.hqhub.dto.CadastroPublicacaoRelacionadaDTO;
import br.com.hqhub.dto.PublicacaoRelacionadaRespostaDTO;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.PublicacaoRelacionada;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.PublicacaoRelacionadaMapper;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.PublicacaoRelacionadaRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class PublicacaoRelacionadaService {

    private final PublicacaoRelacionadaRepository publicacaoRelacionadaRepository;
    private final EdicaoRepository edicaoRepository;
    private final PublicacaoRelacionadaMapper publicacaoRelacionadaMapper;

    public PublicacaoRelacionadaService(
            PublicacaoRelacionadaRepository publicacaoRelacionadaRepository,
            EdicaoRepository edicaoRepository,
            PublicacaoRelacionadaMapper publicacaoRelacionadaMapper) {
        this.publicacaoRelacionadaRepository = publicacaoRelacionadaRepository;
        this.edicaoRepository = edicaoRepository;
        this.publicacaoRelacionadaMapper = publicacaoRelacionadaMapper;
    }

    @Transactional
    public PublicacaoRelacionadaRespostaDTO cadastrar(CadastroPublicacaoRelacionadaDTO dto) {
        if (dto.edicaoOrigemId().equals(dto.edicaoDestinoId())) {
            throw new RegraNegocioException("Edição de origem e edição de destino devem ser diferentes.");
        }

        Edicao origem = buscarEdicaoPorId(dto.edicaoOrigemId());
        Edicao destino = buscarEdicaoPorId(dto.edicaoDestinoId());

        if (publicacaoRelacionadaRepository.existePorOrigemDestinoTipo(dto.edicaoOrigemId(), dto.edicaoDestinoId(), dto.tipo())) {
            throw new RegraNegocioException("Esta publicação relacionada já está cadastrada.");
        }

        PublicacaoRelacionada publicacao = publicacaoRelacionadaMapper.paraEntidade(dto, origem, destino);
        publicacaoRelacionadaRepository.persist(publicacao);

        return publicacaoRelacionadaMapper.paraResposta(publicacao);
    }

    @Transactional
    public List<PublicacaoRelacionadaRespostaDTO> listarPorEdicao(Long edicaoId) {
        buscarEdicaoPorId(edicaoId);

        return publicacaoRelacionadaRepository
                .list("edicaoOrigem.id = ?1 or edicaoDestino.id = ?1", edicaoId)
                .stream()
                .sorted(Comparator.comparing(PublicacaoRelacionada::getTipo)
                        .thenComparing(item -> item.getEdicaoDestino().getSerie().getTitulo())
                        .thenComparing(item -> item.getEdicaoDestino().getNumero()))
                .map(publicacaoRelacionadaMapper::paraResposta)
                .toList();
    }

    @Transactional
    public void remover(Long id) {
        PublicacaoRelacionada publicacao = publicacaoRelacionadaRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Publicação relacionada não encontrada."));
        publicacaoRelacionadaRepository.delete(publicacao);
    }

    private Edicao buscarEdicaoPorId(Long id) {
        return edicaoRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Edição não encontrada."));
    }
}
