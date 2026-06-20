package br.com.hqhub.service;

import java.util.List;

import br.com.hqhub.dto.AtualizacaoSerieDTO;
import br.com.hqhub.dto.CadastroSerieDTO;
import br.com.hqhub.dto.PaginaRespostaDTO;
import br.com.hqhub.dto.SerieRespostaDTO;
import br.com.hqhub.entity.Editora;
import br.com.hqhub.entity.Serie;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.SerieMapper;
import br.com.hqhub.repository.EditoraRepository;
import br.com.hqhub.repository.SerieRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class SerieService {

    private final SerieRepository serieRepository;
    private final EditoraRepository editoraRepository;
    private final SerieMapper serieMapper;

    public SerieService(SerieRepository serieRepository, EditoraRepository editoraRepository, SerieMapper serieMapper) {
        this.serieRepository = serieRepository;
        this.editoraRepository = editoraRepository;
        this.serieMapper = serieMapper;
    }

    @Transactional
    public SerieRespostaDTO cadastrar(CadastroSerieDTO dto) {
        validarPeriodo(dto.anoInicio(), dto.anoFim());

        Editora editora = buscarEditoraPorId(dto.editoraId());

        if (serieRepository.existePorTituloEEditora(dto.titulo(), dto.editoraId())) {
            throw new RegraNegocioException("Já existe uma série cadastrada com este título para esta editora.");
        }

        validarOrigemExterna(dto.fonteExterna(), dto.idExterno());

        if (serieRepository.existePorOrigemExterna(dto.fonteExterna(), dto.idExterno())) {
            throw new RegraNegocioException("Já existe uma série cadastrada com esta origem externa.");
        }

        Serie serie = serieMapper.paraEntidade(dto, editora);
        serieRepository.persist(serie);

        return serieMapper.paraResposta(serie);
    }

    @Transactional
    public SerieRespostaDTO atualizar(Long id, AtualizacaoSerieDTO dto) {
        validarPeriodo(dto.anoInicio(), dto.anoFim());

        Serie serie = buscarEntidadePorId(id);
        Editora editora = buscarEditoraPorId(dto.editoraId());

        if (serieRepository.existePorTituloEEditoraEmOutraSerie(dto.titulo(), dto.editoraId(), id)) {
            throw new RegraNegocioException("Já existe uma série cadastrada com este título para esta editora.");
        }

        validarOrigemExterna(dto.fonteExterna(), dto.idExterno());

        if (serieRepository.existePorOrigemExternaEmOutraSerie(dto.fonteExterna(), dto.idExterno(), id)) {
            throw new RegraNegocioException("Já existe uma série cadastrada com esta origem externa.");
        }

        serieMapper.atualizarEntidade(serie, dto, editora);

        return serieMapper.paraResposta(serie);
    }

    public SerieRespostaDTO buscarPorId(Long id) {
        return serieMapper.paraResposta(buscarEntidadePorId(id));
    }

    public List<SerieRespostaDTO> listarTodos() {
        return serieRepository.list("titulo")
                .stream()
                .map(serieMapper::paraResposta)
                .toList();
    }

    public PaginaRespostaDTO<SerieRespostaDTO> listarPaginado(String busca, String inicial, int pagina, int tamanho) {
        int paginaTratada = Math.max(pagina, 0);
        int tamanhoTratado = Math.min(Math.max(tamanho, 1), 100);
        long totalItens = serieRepository.contarComBusca(busca, inicial);
        int totalPaginas = (int) Math.ceil((double) totalItens / tamanhoTratado);

        List<SerieRespostaDTO> itens = serieRepository.buscarPaginado(busca, inicial, paginaTratada, tamanhoTratado)
                .stream()
                .map(serieMapper::paraResposta)
                .toList();

        return new PaginaRespostaDTO<>(itens, paginaTratada, tamanhoTratado, totalItens, totalPaginas);
    }

    @Transactional
    public void remover(Long id) {
        Serie serie = buscarEntidadePorId(id);
        serieRepository.delete(serie);
    }

    private Serie buscarEntidadePorId(Long id) {
        return serieRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Série não encontrada."));
    }

    private Editora buscarEditoraPorId(Long id) {
        return editoraRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Editora não encontrada."));
    }

    private void validarPeriodo(Integer anoInicio, Integer anoFim) {
        if (anoInicio != null && anoFim != null && anoFim < anoInicio) {
            throw new RegraNegocioException("Ano de fim não pode ser menor que o ano de início.");
        }
    }

    private void validarOrigemExterna(String fonteExterna, String idExterno) {
        if ((fonteExterna == null) != (idExterno == null)) {
            throw new RegraNegocioException("Fonte externa e id externo devem ser informados juntos.");
        }
    }
}
