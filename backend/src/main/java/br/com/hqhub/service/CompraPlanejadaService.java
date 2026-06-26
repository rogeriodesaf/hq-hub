package br.com.hqhub.service;

import java.util.Comparator;
import java.util.List;

import br.com.hqhub.dto.AtualizacaoCompraPlanejadaDTO;
import br.com.hqhub.dto.CadastroCompraPlanejadaDTO;
import br.com.hqhub.dto.CompraPlanejadaRespostaDTO;
import br.com.hqhub.entity.CompraPlanejada;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.CompraPlanejadaMapper;
import br.com.hqhub.repository.CompraPlanejadaRepository;
import br.com.hqhub.repository.EdicaoRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class CompraPlanejadaService {

    private final CompraPlanejadaRepository compraPlanejadaRepository;
    private final EdicaoRepository edicaoRepository;
    private final CompraPlanejadaMapper compraPlanejadaMapper;
    private final UsuarioAutenticadoService usuarioAutenticadoService;

    public CompraPlanejadaService(
            CompraPlanejadaRepository compraPlanejadaRepository,
            EdicaoRepository edicaoRepository,
            CompraPlanejadaMapper compraPlanejadaMapper,
            UsuarioAutenticadoService usuarioAutenticadoService) {
        this.compraPlanejadaRepository = compraPlanejadaRepository;
        this.edicaoRepository = edicaoRepository;
        this.compraPlanejadaMapper = compraPlanejadaMapper;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
    }

    @Transactional
    public CompraPlanejadaRespostaDTO cadastrar(CadastroCompraPlanejadaDTO dto) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        Edicao edicao = buscarEdicaoPorId(dto.edicaoId());

        if (compraPlanejadaRepository.existePorUsuarioEdicaoMesAno(usuario.getId(), dto.edicaoId(), dto.mes(), dto.ano())) {
            throw new RegraNegocioException("Esta edição já está planejada para este mês.");
        }

        CompraPlanejada compra = compraPlanejadaMapper.paraEntidade(dto, usuario, edicao);
        compraPlanejadaRepository.persist(compra);

        return compraPlanejadaMapper.paraResposta(compra);
    }

    @Transactional
    public CompraPlanejadaRespostaDTO atualizar(Long id, AtualizacaoCompraPlanejadaDTO dto) {
        CompraPlanejada compra = buscarDoUsuarioPorId(id);
        compraPlanejadaMapper.atualizarEntidade(compra, dto);

        return compraPlanejadaMapper.paraResposta(compra);
    }

    @Transactional
    public CompraPlanejadaRespostaDTO buscarPorId(Long id) {
        return compraPlanejadaMapper.paraResposta(buscarDoUsuarioPorId(id));
    }

    @Transactional
    public List<CompraPlanejadaRespostaDTO> listar(Integer mes, Integer ano) {
        return listar(mes, ano, null, null, null, null);
    }

    @Transactional
    public List<CompraPlanejadaRespostaDTO> listar(Integer mes, Integer ano, Integer mesInicio, Integer anoInicio, Integer mesFim, Integer anoFim) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        List<CompraPlanejada> compras;
        if (mesInicio != null && anoInicio != null && mesFim != null && anoFim != null) {
            compras = compraPlanejadaRepository.list(
                    "usuario.id = ?1 and (ano > ?2 or (ano = ?2 and mes >= ?3)) and (ano < ?4 or (ano = ?4 and mes <= ?5))",
                    usuario.getId(), anoInicio, mesInicio, anoFim, mesFim);
        } else if (mes != null && ano != null) {
            compras = compraPlanejadaRepository.list("usuario.id = ?1 and mes = ?2 and ano = ?3", usuario.getId(), mes, ano);
        } else {
            compras = compraPlanejadaRepository.list("usuario.id", usuario.getId());
        }

        return compras.stream()
                .sorted(Comparator.comparing(CompraPlanejada::getAno)
                        .thenComparing(CompraPlanejada::getMes)
                        .thenComparing(compra -> compra.getEdicao().getSerie().getTitulo())
                        .thenComparing(compra -> compra.getEdicao().getNumero()))
                .map(compraPlanejadaMapper::paraResposta)
                .toList();
    }

    @Transactional
    public void remover(Long id) {
        CompraPlanejada compra = buscarDoUsuarioPorId(id);
        compraPlanejadaRepository.delete(compra);
    }

    private CompraPlanejada buscarDoUsuarioPorId(Long id) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();

        return compraPlanejadaRepository.find("id = ?1 and usuario.id = ?2", id, usuario.getId())
                .firstResultOptional()
                .orElseThrow(() -> new RecursoNaoEncontradoException("Compra planejada não encontrada."));
    }

    private Edicao buscarEdicaoPorId(Long id) {
        return edicaoRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Edição não encontrada."));
    }
}
