package br.com.hqhub.service;

import java.util.Comparator;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import br.com.hqhub.dto.AtualizacaoEdicaoDTO;
import br.com.hqhub.dto.AtualizacaoCapaEdicaoDTO;
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
import jakarta.persistence.EntityManager;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class EdicaoService {

    private static final Pattern PRIMEIRO_NUMERO = Pattern.compile("\\d+");

    private final EdicaoRepository edicaoRepository;
    private final SerieRepository serieRepository;
    private final EdicaoMapper edicaoMapper;
    private final EntityManager entityManager;

    public EdicaoService(
            EdicaoRepository edicaoRepository,
            SerieRepository serieRepository,
            EdicaoMapper edicaoMapper,
            EntityManager entityManager) {
        this.edicaoRepository = edicaoRepository;
        this.serieRepository = serieRepository;
        this.edicaoMapper = edicaoMapper;
        this.entityManager = entityManager;
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
    public EdicaoRespostaDTO atualizarCapa(Long id, AtualizacaoCapaEdicaoDTO dto) {
        Edicao edicao = buscarEntidadePorId(id);
        edicao.setUrlCapa(dto.urlCapa());
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

        List<Edicao> edicoes = serieId == null
                ? edicaoRepository.buscarPaginado(serieId, busca, paginaTratada, tamanhoTratado)
                : edicaoRepository.buscarTodosComBusca(serieId, busca)
                        .stream()
                        .sorted(this::compararNumeroEdicao)
                        .skip((long) paginaTratada * tamanhoTratado)
                        .limit(tamanhoTratado)
                        .toList();

        List<EdicaoRespostaDTO> itens = edicoes.stream()
                .map(edicaoMapper::paraResposta)
                .toList();

        return new PaginaRespostaDTO<>(itens, paginaTratada, tamanhoTratado, totalItens, totalPaginas);
    }

    @Transactional
    public void remover(Long id) {
        Edicao edicao = buscarEntidadePorId(id);
        validarExclusaoEdicao(edicao.getId());
        removerVinculosCatalogo(edicao.getId());
        edicaoRepository.delete(edicao);
    }

    private void validarExclusaoEdicao(Long id) {
        long itensColecao = contarPorEdicao("select count(*) from itens_colecao where edicao_id = :edicaoId", id);
        long comprasPlanejadas = contarPorEdicao("select count(*) from compras_planejadas where edicao_id = :edicaoId", id);

        if (itensColecao > 0 || comprasPlanejadas > 0) {
            throw new RegraNegocioException(
                    "Esta edição está vinculada a uma coleção ou compra planejada. Remova esses vínculos antes de excluir.");
        }
    }

    private void removerVinculosCatalogo(Long id) {
        executarPorEdicao("delete from contribuicoes_catalogo where edicao_destino_id = :edicaoId", id);
        executarPorEdicao("delete from contribuicoes_catalogo where edicao_id = :edicaoId", id);
        executarPorEdicao("delete from publicacoes_relacionadas where edicao_origem_id = :edicaoId or edicao_destino_id = :edicaoId", id);
        executarPorEdicao("delete from publicacoes_historias where edicao_original_id = :edicaoId or edicao_publicada_id = :edicaoId", id);
        executarPorEdicao("delete from conteudos_edicoes where edicao_id = :edicaoId", id);
        executarPorEdicao("delete from links_edicoes where edicao_id = :edicaoId", id);
        executarPorEdicao("delete from creditos_edicoes where edicao_id = :edicaoId", id);
    }

    private long contarPorEdicao(String sql, Long id) {
        Object resultado = entityManager.createNativeQuery(sql)
                .setParameter("edicaoId", id)
                .getSingleResult();
        return ((Number) resultado).longValue();
    }

    private int executarPorEdicao(String sql, Long id) {
        return entityManager.createNativeQuery(sql)
                .setParameter("edicaoId", id)
                .executeUpdate();
    }

    private Edicao buscarEntidadePorId(Long id) {
        return edicaoRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Edição não encontrada."));
    }

    private Serie buscarSeriePorId(Long id) {
        return serieRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Série não encontrada."));
    }

    private int compararNumeroEdicao(Edicao primeira, Edicao segunda) {
        int numeroPrimeira = extrairPrimeiroNumero(primeira.getNumero());
        int numeroSegunda = extrairPrimeiroNumero(segunda.getNumero());

        if (numeroPrimeira != numeroSegunda) {
            return Integer.compare(numeroPrimeira, numeroSegunda);
        }

        return primeira.getNumero().compareToIgnoreCase(segunda.getNumero());
    }

    private int extrairPrimeiroNumero(String valor) {
        if (valor == null) {
            return Integer.MAX_VALUE;
        }

        Matcher matcher = PRIMEIRO_NUMERO.matcher(valor);
        return matcher.find() ? Integer.parseInt(matcher.group()) : Integer.MAX_VALUE;
    }

    private void validarOrigemExterna(String fonteExterna, String idExterno) {
        if ((fonteExterna == null) != (idExterno == null)) {
            throw new RegraNegocioException("Fonte externa e id externo devem ser informados juntos.");
        }
    }
}
