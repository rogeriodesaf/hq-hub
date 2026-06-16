package br.com.hqhub.service;

import java.util.Comparator;
import java.util.List;

import br.com.hqhub.dto.AtualizacaoLinkEdicaoDTO;
import br.com.hqhub.dto.CadastroLinkEdicaoDTO;
import br.com.hqhub.dto.LinkEdicaoRespostaDTO;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.LinkEdicao;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.LinkEdicaoMapper;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.LinkEdicaoRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class LinkEdicaoService {

    private final LinkEdicaoRepository linkEdicaoRepository;
    private final EdicaoRepository edicaoRepository;
    private final LinkEdicaoMapper linkEdicaoMapper;

    public LinkEdicaoService(
            LinkEdicaoRepository linkEdicaoRepository,
            EdicaoRepository edicaoRepository,
            LinkEdicaoMapper linkEdicaoMapper) {
        this.linkEdicaoRepository = linkEdicaoRepository;
        this.edicaoRepository = edicaoRepository;
        this.linkEdicaoMapper = linkEdicaoMapper;
    }

    @Transactional
    public LinkEdicaoRespostaDTO cadastrar(CadastroLinkEdicaoDTO dto) {
        Edicao edicao = buscarEdicaoPorId(dto.edicaoId());

        if (linkEdicaoRepository.existePorEdicaoEUrl(dto.edicaoId(), dto.url())) {
            throw new RegraNegocioException("Esta URL já está cadastrada para esta edição.");
        }

        LinkEdicao link = linkEdicaoMapper.paraEntidade(dto, edicao);
        linkEdicaoRepository.persist(link);

        return linkEdicaoMapper.paraResposta(link);
    }

    @Transactional
    public LinkEdicaoRespostaDTO atualizar(Long id, AtualizacaoLinkEdicaoDTO dto) {
        LinkEdicao link = buscarEntidadePorId(id);

        if (linkEdicaoRepository.existePorEdicaoEUrlEmOutroLink(link.getEdicao().getId(), dto.url(), id)) {
            throw new RegraNegocioException("Esta URL já está cadastrada para esta edição.");
        }

        linkEdicaoMapper.atualizarEntidade(link, dto);

        return linkEdicaoMapper.paraResposta(link);
    }

    @Transactional
    public LinkEdicaoRespostaDTO buscarPorId(Long id) {
        return linkEdicaoMapper.paraResposta(buscarEntidadePorId(id));
    }

    @Transactional
    public List<LinkEdicaoRespostaDTO> listarPorEdicao(Long edicaoId) {
        buscarEdicaoPorId(edicaoId);

        return linkEdicaoRepository.list("edicao.id", edicaoId)
                .stream()
                .sorted(Comparator.comparing(LinkEdicao::getTipo).thenComparing(LinkEdicao::getTitulo))
                .map(linkEdicaoMapper::paraResposta)
                .toList();
    }

    @Transactional
    public void remover(Long id) {
        LinkEdicao link = buscarEntidadePorId(id);
        linkEdicaoRepository.delete(link);
    }

    private LinkEdicao buscarEntidadePorId(Long id) {
        return linkEdicaoRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Link da edição não encontrado."));
    }

    private Edicao buscarEdicaoPorId(Long id) {
        return edicaoRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Edição não encontrada."));
    }
}
