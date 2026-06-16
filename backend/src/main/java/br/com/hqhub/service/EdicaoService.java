package br.com.hqhub.service;

import java.util.Comparator;
import java.util.List;

import br.com.hqhub.dto.AtualizacaoEdicaoDTO;
import br.com.hqhub.dto.CadastroEdicaoDTO;
import br.com.hqhub.dto.EdicaoRespostaDTO;
import br.com.hqhub.dto.PaginaRespostaDTO;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.Serie;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.EdicaoMapper;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.SerieRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class EdicaoService {

    private final EdicaoRepository edicaoRepository;
    private final SerieRepository serieRepository;
    private final EdicaoMapper edicaoMapper;

    public EdicaoService(EdicaoRepository edicaoRepository, SerieRepository serieRepository, EdicaoMapper edicaoMapper) {
        this.edicaoRepository = edicaoRepository;
        this.serieRepository = serieRepository;
        this.edicaoMapper = edicaoMapper;
    }

    @Transactional
    public EdicaoRespostaDTO cadastrar(CadastroEdicaoDTO dto) {
        Serie serie = buscarSeriePorId(dto.serieId());

        if (edicaoRepository.existePorNumeroESerie(dto.numero(), dto.serieId())) {
            throw new RegraNegocioException("Já existe uma edição cadastrada com este número para esta série.");
        }

        validarOrigemExterna(dto.fonteExterna(), dto.idExterno());

        if (edicaoRepository.existePorOrigemExterna(dto.fonteExterna(), dto.idExterno())) {
            throw new RegraNegocioException("Já existe uma edição cadastrada com esta origem externa.");
        }

        Edicao edicao = edicaoMapper.paraEntidade(dto, serie);
        edicaoRepository.persist(edicao);

        return edicaoMapper.paraResposta(edicao);
    }

    @Transactional
    public EdicaoRespostaDTO atualizar(Long id, AtualizacaoEdicaoDTO dto) {
        Edicao edicao = buscarEntidadePorId(id);
        Serie serie = buscarSeriePorId(dto.serieId());

        if (edicaoRepository.existePorNumeroESerieEmOutraEdicao(dto.numero(), dto.serieId(), id)) {
            throw new RegraNegocioException("Já existe uma edição cadastrada com este número para esta série.");
        }

        validarOrigemExterna(dto.fonteExterna(), dto.idExterno());

        if (edicaoRepository.existePorOrigemExternaEmOutraEdicao(dto.fonteExterna(), dto.idExterno(), id)) {
            throw new RegraNegocioException("Já existe uma edição cadastrada com esta origem externa.");
        }

        edicaoMapper.atualizarEntidade(edicao, dto, serie);

        return edicaoMapper.paraResposta(edicao);
    }

    @Transactional
    public EdicaoRespostaDTO buscarPorId(Long id) {
        return edicaoMapper.paraResposta(buscarEntidadePorId(id));
    }

    @Transactional
    public List<EdicaoRespostaDTO> listarTodos() {
        return edicaoRepository.listAll()
                .stream()
                .sorted(Comparator.comparing((Edicao edicao) -> edicao.getSerie().getTitulo())
                        .thenComparing(Edicao::getNumero))
                .map(edicaoMapper::paraResposta)
                .toList();
    }

    @Transactional
    public List<EdicaoRespostaDTO> listarPorSerie(Long serieId) {
        buscarSeriePorId(serieId);

        return edicaoRepository.list("serie.id", serieId)
                .stream()
                .sorted(Comparator.comparing(Edicao::getNumero))
                .map(edicaoMapper::paraResposta)
                .toList();
    }

    @Transactional
    public PaginaRespostaDTO<EdicaoRespostaDTO> listarPaginado(Long serieId, String busca, int pagina, int tamanho) {
        if (serieId != null) {
            buscarSeriePorId(serieId);
        }

        int paginaTratada = Math.max(pagina, 0);
        int tamanhoTratado = Math.min(Math.max(tamanho, 1), 100);
        long totalItens = edicaoRepository.contarComBusca(serieId, busca);
        int totalPaginas = (int) Math.ceil((double) totalItens / tamanhoTratado);

        List<EdicaoRespostaDTO> itens = edicaoRepository.buscarPaginado(serieId, busca, paginaTratada, tamanhoTratado)
                .stream()
                .map(edicaoMapper::paraResposta)
                .toList();

        return new PaginaRespostaDTO<>(itens, paginaTratada, tamanhoTratado, totalItens, totalPaginas);
    }

    @Transactional
    public void remover(Long id) {
        Edicao edicao = buscarEntidadePorId(id);
        edicaoRepository.delete(edicao);
    }

    private Edicao buscarEntidadePorId(Long id) {
        return edicaoRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Edição não encontrada."));
    }

    private Serie buscarSeriePorId(Long id) {
        return serieRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Série não encontrada."));
    }

    private void validarOrigemExterna(String fonteExterna, String idExterno) {
        if ((fonteExterna == null) != (idExterno == null)) {
            throw new RegraNegocioException("Fonte externa e id externo devem ser informados juntos.");
        }
    }
}
