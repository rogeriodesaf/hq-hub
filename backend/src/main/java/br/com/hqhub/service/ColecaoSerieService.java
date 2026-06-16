package br.com.hqhub.service;

import java.util.Comparator;
import java.util.List;

import br.com.hqhub.dto.AtualizacaoColecaoSerieDTO;
import br.com.hqhub.dto.CadastroColecaoSerieDTO;
import br.com.hqhub.dto.ColecaoSerieRespostaDTO;
import br.com.hqhub.entity.ColecaoSerie;
import br.com.hqhub.entity.Serie;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.ColecaoSerieMapper;
import br.com.hqhub.repository.ColecaoSerieRepository;
import br.com.hqhub.repository.SerieRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class ColecaoSerieService {

    private final ColecaoSerieRepository colecaoSerieRepository;
    private final SerieRepository serieRepository;
    private final ColecaoSerieMapper colecaoSerieMapper;
    private final UsuarioAutenticadoService usuarioAutenticadoService;

    public ColecaoSerieService(
            ColecaoSerieRepository colecaoSerieRepository,
            SerieRepository serieRepository,
            ColecaoSerieMapper colecaoSerieMapper,
            UsuarioAutenticadoService usuarioAutenticadoService) {
        this.colecaoSerieRepository = colecaoSerieRepository;
        this.serieRepository = serieRepository;
        this.colecaoSerieMapper = colecaoSerieMapper;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
    }

    @Transactional
    public ColecaoSerieRespostaDTO cadastrar(CadastroColecaoSerieDTO dto) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        Serie serie = buscarSeriePorId(dto.serieId());

        if (colecaoSerieRepository.existePorUsuarioESerie(usuario.getId(), dto.serieId())) {
            throw new RegraNegocioException("Esta série já está organizada na sua coleção.");
        }

        ColecaoSerie colecaoSerie = colecaoSerieMapper.paraEntidade(dto, usuario, serie);
        colecaoSerieRepository.persist(colecaoSerie);

        return colecaoSerieMapper.paraResposta(colecaoSerie);
    }

    @Transactional
    public ColecaoSerieRespostaDTO atualizar(Long id, AtualizacaoColecaoSerieDTO dto) {
        ColecaoSerie colecaoSerie = buscarDoUsuarioPorId(id);
        colecaoSerieMapper.atualizarEntidade(colecaoSerie, dto);

        return colecaoSerieMapper.paraResposta(colecaoSerie);
    }

    @Transactional
    public ColecaoSerieRespostaDTO buscarPorId(Long id) {
        return colecaoSerieMapper.paraResposta(buscarDoUsuarioPorId(id));
    }

    @Transactional
    public List<ColecaoSerieRespostaDTO> listarTodos() {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();

        return colecaoSerieRepository.list("usuario.id", usuario.getId())
                .stream()
                .sorted(Comparator.comparing((ColecaoSerie item) -> item.getPrioridade() == null ? 999 : item.getPrioridade())
                        .thenComparing(item -> item.getSerie().getTitulo()))
                .map(colecaoSerieMapper::paraResposta)
                .toList();
    }

    @Transactional
    public void remover(Long id) {
        ColecaoSerie colecaoSerie = buscarDoUsuarioPorId(id);
        colecaoSerieRepository.delete(colecaoSerie);
    }

    private ColecaoSerie buscarDoUsuarioPorId(Long id) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();

        return colecaoSerieRepository.find("id = ?1 and usuario.id = ?2", id, usuario.getId())
                .firstResultOptional()
                .orElseThrow(() -> new RecursoNaoEncontradoException("Série da coleção não encontrada."));
    }

    private Serie buscarSeriePorId(Long id) {
        return serieRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Série não encontrada."));
    }
}
