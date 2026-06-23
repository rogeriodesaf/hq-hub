package br.com.hqhub.service;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import br.com.hqhub.dto.AtualizacaoHistoriaDTO;
import br.com.hqhub.dto.CadastroConteudoEdicaoDTO;
import br.com.hqhub.dto.CadastroHistoriaDTO;
import br.com.hqhub.dto.CadastroPublicacaoHistoriaDTO;
import br.com.hqhub.dto.ConteudoEdicaoRespostaDTO;
import br.com.hqhub.dto.CruzamentoEdicaoRespostaDTO;
import br.com.hqhub.dto.HistoriaRespostaDTO;
import br.com.hqhub.dto.PublicacaoHistoriaRespostaDTO;
import br.com.hqhub.dto.SugestaoPublicacaoHistoriaDTO;
import br.com.hqhub.entity.ConteudoEdicao;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.Historia;
import br.com.hqhub.entity.PublicacaoHistoria;
import br.com.hqhub.entity.StatusPublicacaoHistoria;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.ConteudoEdicaoMapper;
import br.com.hqhub.mapper.EdicaoMapper;
import br.com.hqhub.mapper.HistoriaMapper;
import br.com.hqhub.mapper.PublicacaoHistoriaMapper;
import br.com.hqhub.repository.ConteudoEdicaoRepository;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.HistoriaRepository;
import br.com.hqhub.repository.PublicacaoHistoriaRepository;
import io.quarkus.panache.common.Sort;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class HistoriaService {

    private final HistoriaRepository historiaRepository;
    private final EdicaoRepository edicaoRepository;
    private final ConteudoEdicaoRepository conteudoEdicaoRepository;
    private final PublicacaoHistoriaRepository publicacaoHistoriaRepository;
    private final HistoriaMapper historiaMapper;
    private final ConteudoEdicaoMapper conteudoEdicaoMapper;
    private final PublicacaoHistoriaMapper publicacaoHistoriaMapper;
    private final EdicaoMapper edicaoMapper;

    public HistoriaService(
            HistoriaRepository historiaRepository,
            EdicaoRepository edicaoRepository,
            ConteudoEdicaoRepository conteudoEdicaoRepository,
            PublicacaoHistoriaRepository publicacaoHistoriaRepository,
            HistoriaMapper historiaMapper,
            ConteudoEdicaoMapper conteudoEdicaoMapper,
            PublicacaoHistoriaMapper publicacaoHistoriaMapper,
            EdicaoMapper edicaoMapper) {
        this.historiaRepository = historiaRepository;
        this.edicaoRepository = edicaoRepository;
        this.conteudoEdicaoRepository = conteudoEdicaoRepository;
        this.publicacaoHistoriaRepository = publicacaoHistoriaRepository;
        this.historiaMapper = historiaMapper;
        this.conteudoEdicaoMapper = conteudoEdicaoMapper;
        this.publicacaoHistoriaMapper = publicacaoHistoriaMapper;
        this.edicaoMapper = edicaoMapper;
    }

    @Transactional
    public HistoriaRespostaDTO cadastrarHistoria(CadastroHistoriaDTO dto) {
        validarOrigemExterna(dto.fonteExterna(), dto.idExterno());

        if (historiaRepository.existePorOrigemExterna(dto.fonteExterna(), dto.idExterno())) {
            throw new RegraNegocioException("Já existe uma história cadastrada com esta origem externa.");
        }

        Historia historia = historiaMapper.paraEntidade(dto);
        historiaRepository.persist(historia);
        return historiaMapper.paraResposta(historia);
    }

    @Transactional
    public HistoriaRespostaDTO atualizarHistoria(Long id, AtualizacaoHistoriaDTO dto) {
        Historia historia = buscarHistoriaPorId(id);
        historiaMapper.atualizarEntidade(historia, dto);
        return historiaMapper.paraResposta(historia);
    }

    public HistoriaRespostaDTO buscarHistoriaPorIdResposta(Long id) {
        return historiaMapper.paraResposta(buscarHistoriaPorId(id));
    }

    public List<HistoriaRespostaDTO> listarHistorias() {
        return historiaRepository.listAll(Sort.by("titulo"))
                .stream()
                .map(historiaMapper::paraResposta)
                .toList();
    }

    @Transactional
    public ConteudoEdicaoRespostaDTO adicionarConteudo(CadastroConteudoEdicaoDTO dto) {
        Edicao edicao = buscarEdicaoPorId(dto.edicaoId());
        Historia historia = buscarHistoriaPorId(dto.historiaId());

        if (conteudoEdicaoRepository.existePorEdicaoEOrdem(dto.edicaoId(), dto.ordem())) {
            throw new RegraNegocioException("Já existe conteúdo cadastrado nesta ordem para esta edição.");
        }

        ConteudoEdicao conteudo = conteudoEdicaoMapper.paraEntidade(dto, edicao, historia);
        conteudoEdicaoRepository.persist(conteudo);
        return conteudoEdicaoMapper.paraResposta(conteudo);
    }

    @Transactional
    public List<ConteudoEdicaoRespostaDTO> listarConteudosPorEdicao(Long edicaoId) {
        buscarEdicaoPorId(edicaoId);
        return conteudoEdicaoRepository.listarPorEdicao(edicaoId)
                .stream()
                .map(conteudoEdicaoMapper::paraResposta)
                .toList();
    }

    @Transactional
    public PublicacaoHistoriaRespostaDTO cadastrarPublicacao(CadastroPublicacaoHistoriaDTO dto) {
        if (dto.edicaoOriginalId().equals(dto.edicaoPublicadaId())) {
            throw new RegraNegocioException("Edição original e edição publicada devem ser diferentes.");
        }

        Historia historia = buscarHistoriaPorId(dto.historiaId());
        Edicao original = buscarEdicaoPorId(dto.edicaoOriginalId());
        Edicao publicada = buscarEdicaoPorId(dto.edicaoPublicadaId());

        if (publicacaoHistoriaRepository.existePorHistoriaEEdicaoPublicada(dto.historiaId(), dto.edicaoPublicadaId())) {
            throw new RegraNegocioException("Esta história já está vinculada a esta edição publicada.");
        }

        PublicacaoHistoria publicacao = publicacaoHistoriaMapper.paraEntidade(dto, historia, original, publicada);
        publicacaoHistoriaRepository.persist(publicacao);
        return publicacaoHistoriaMapper.paraResposta(publicacao);
    }

    @Transactional
    public PublicacaoHistoriaRespostaDTO sugerirPublicacao(Long historiaId, SugestaoPublicacaoHistoriaDTO dto) {
        Historia historia = buscarHistoriaPorId(historiaId);
        Edicao publicada = buscarEdicaoPorId(dto.edicaoId());
        ConteudoEdicao conteudoOriginal = conteudoEdicaoRepository.buscarPrimeiroPorHistoria(historiaId)
                .orElseThrow(() -> new RegraNegocioException(
                        "Cadastre primeiro em qual edição a história aparece originalmente."));
        Edicao original = conteudoOriginal.getEdicao();

        if (original.getId().equals(publicada.getId())) {
            throw new RegraNegocioException("A edição publicada deve ser diferente da edição original.");
        }

        if (publicacaoHistoriaRepository.existePorHistoriaEEdicaoPublicada(historiaId, dto.edicaoId())) {
            throw new RegraNegocioException("Esta história já está vinculada a esta edição publicada.");
        }

        PublicacaoHistoria publicacao = new PublicacaoHistoria();
        publicacao.setHistoria(historia);
        publicacao.setEdicaoOriginal(original);
        publicacao.setEdicaoPublicada(publicada);
        publicacao.setStatus(StatusPublicacaoHistoria.DESCONHECIDA);
        publicacao.setTipoPublicacaoHistoria(dto.tipoPublicacaoHistoria());
        publicacao.setFonteInformacao(dto.fonteInformacao());
        publicacao.setUrlFonteInformacao(dto.urlFonteInformacao());
        publicacao.setFonteExterna(dto.fonteInformacao());
        publicacao.setUrlOrigem(dto.urlFonteInformacao());
        publicacao.setObservacoes(dto.observacao());
        // TODO: vincular usuarioCriador ao usuário autenticado quando a moderação de contribuições for consolidada.
        publicacaoHistoriaRepository.persist(publicacao);

        return publicacaoHistoriaMapper.paraResposta(publicacao);
    }

    @Transactional
    public List<PublicacaoHistoriaRespostaDTO> listarPublicacoesPorHistoria(Long historiaId) {
        buscarHistoriaPorId(historiaId);
        return publicacaoHistoriaRepository.listarPorHistoria(historiaId)
                .stream()
                .map(publicacaoHistoriaMapper::paraResposta)
                .toList();
    }

    @Transactional
    public List<PublicacaoHistoriaRespostaDTO> listarPublicacoesPorEdicaoPublicada(Long edicaoPublicadaId) {
        buscarEdicaoPorId(edicaoPublicadaId);
        return publicacaoHistoriaRepository.listarPorEdicaoPublicada(edicaoPublicadaId)
                .stream()
                .map(publicacaoHistoriaMapper::paraResposta)
                .toList();
    }

    @Transactional
    public List<PublicacaoHistoriaRespostaDTO> listarPublicacoesPorEdicaoOriginal(Long edicaoOriginalId) {
        buscarEdicaoPorId(edicaoOriginalId);
        return publicacaoHistoriaRepository.listarPorEdicaoOriginal(edicaoOriginalId)
                .stream()
                .map(publicacaoHistoriaMapper::paraResposta)
                .toList();
    }

    @Transactional
    public CruzamentoEdicaoRespostaDTO cruzarEdicoes(Long edicaoOriginalId, Long edicaoComparadaId) {
        Edicao original = buscarEdicaoPorId(edicaoOriginalId);
        Edicao comparada = buscarEdicaoPorId(edicaoComparadaId);
        List<ConteudoEdicao> conteudosOriginais = conteudoEdicaoRepository.listarPorEdicao(edicaoOriginalId);
        List<PublicacaoHistoria> publicacoes = publicacaoHistoriaRepository
                .listarPorEdicaoOriginalEPublicada(edicaoOriginalId, edicaoComparadaId);

        Set<Long> idsHistoriasIncluidas = publicacoes.stream()
                .map(publicacao -> publicacao.getHistoria().getId())
                .collect(Collectors.toSet());

        List<ConteudoEdicaoRespostaDTO> conteudosFora = conteudosOriginais.stream()
                .filter(conteudo -> !idsHistoriasIncluidas.contains(conteudo.getHistoria().getId()))
                .map(conteudoEdicaoMapper::paraResposta)
                .toList();

        List<ConteudoEdicaoRespostaDTO> conteudosOriginaisResposta = conteudosOriginais.stream()
                .map(conteudoEdicaoMapper::paraResposta)
                .toList();

        List<PublicacaoHistoriaRespostaDTO> historiasIncluidas = publicacoes.stream()
                .map(publicacaoHistoriaMapper::paraResposta)
                .toList();

        return new CruzamentoEdicaoRespostaDTO(
                edicaoMapper.paraResposta(original),
                edicaoMapper.paraResposta(comparada),
                conteudosOriginaisResposta,
                historiasIncluidas,
                conteudosFora,
                conteudosOriginaisResposta.size(),
                historiasIncluidas.size(),
                conteudosFora.size());
    }

    @Transactional
    public void removerConteudo(Long id) {
        ConteudoEdicao conteudo = conteudoEdicaoRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Conteúdo da edição não encontrado."));
        conteudoEdicaoRepository.delete(conteudo);
    }

    @Transactional
    public void removerPublicacao(Long id) {
        PublicacaoHistoria publicacao = publicacaoHistoriaRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Publicação da história não encontrada."));
        publicacaoHistoriaRepository.delete(publicacao);
    }

    private Historia buscarHistoriaPorId(Long id) {
        return historiaRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("História não encontrada."));
    }

    private Edicao buscarEdicaoPorId(Long id) {
        return edicaoRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Edição não encontrada."));
    }

    private void validarOrigemExterna(String fonteExterna, String idExterno) {
        if ((fonteExterna == null) != (idExterno == null)) {
            throw new RegraNegocioException("Fonte externa e id externo devem ser informados juntos.");
        }
    }
}
