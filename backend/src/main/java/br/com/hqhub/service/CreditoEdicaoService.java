package br.com.hqhub.service;

import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;

import br.com.hqhub.dto.CadastroCreditoEdicaoDTO;
import br.com.hqhub.dto.CreditoEdicaoRespostaDTO;
import br.com.hqhub.entity.CreditoEdicao;
import br.com.hqhub.entity.Criador;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.PapelCriador;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.CreditoEdicaoMapper;
import br.com.hqhub.repository.CreditoEdicaoRepository;
import br.com.hqhub.repository.CriadorRepository;
import br.com.hqhub.repository.EdicaoRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class CreditoEdicaoService {

    private final CreditoEdicaoRepository creditoEdicaoRepository;
    private final EdicaoRepository edicaoRepository;
    private final CriadorRepository criadorRepository;
    private final CreditoEdicaoMapper creditoEdicaoMapper;

    public CreditoEdicaoService(
            CreditoEdicaoRepository creditoEdicaoRepository,
            EdicaoRepository edicaoRepository,
            CriadorRepository criadorRepository,
            CreditoEdicaoMapper creditoEdicaoMapper) {
        this.creditoEdicaoRepository = creditoEdicaoRepository;
        this.edicaoRepository = edicaoRepository;
        this.criadorRepository = criadorRepository;
        this.creditoEdicaoMapper = creditoEdicaoMapper;
    }

    @Transactional
    public CreditoEdicaoRespostaDTO cadastrar(CadastroCreditoEdicaoDTO dto) {
        Edicao edicao = buscarEdicaoPorId(dto.edicaoId());
        Criador criador = buscarCriadorPorId(dto.criadorId());

        if (creditoEdicaoRepository.existePorEdicaoCriadorPapel(dto.edicaoId(), dto.criadorId(), dto.papel())) {
            throw new RegraNegocioException("Este crédito já está cadastrado para esta edição.");
        }

        CreditoEdicao credito = creditoEdicaoMapper.paraEntidade(dto, edicao, criador);
        creditoEdicaoRepository.persist(credito);

        return creditoEdicaoMapper.paraResposta(credito);
    }

    @Transactional
    public List<CreditoEdicaoRespostaDTO> listarEdicoesPorCriador(Long criadorId, PapelCriador papel) {
        buscarCriadorPorId(criadorId);

        List<CreditoEdicao> creditos = papel == null
                ? creditoEdicaoRepository.listarPorCriador(criadorId)
                : creditoEdicaoRepository.listarPorCriadorEPapel(criadorId, papel);

        return creditos.stream()
                .sorted(Comparator.comparing((CreditoEdicao credito) -> {
                    LocalDate dataPublicacao = credito.getEdicao().getDataPublicacao();
                    return dataPublicacao == null ? LocalDate.MAX : dataPublicacao;
                }).thenComparing(credito -> credito.getEdicao().getSerie().getTitulo())
                        .thenComparing(credito -> credito.getEdicao().getNumero()))
                .map(creditoEdicaoMapper::paraResposta)
                .toList();
    }

    @Transactional
    public void remover(Long id) {
        CreditoEdicao credito = creditoEdicaoRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Crédito da edição não encontrado."));
        creditoEdicaoRepository.delete(credito);
    }

    private Edicao buscarEdicaoPorId(Long id) {
        return edicaoRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Edição não encontrada."));
    }

    private Criador buscarCriadorPorId(Long id) {
        return criadorRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Criador não encontrado."));
    }
}
