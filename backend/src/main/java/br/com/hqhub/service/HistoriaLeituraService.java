package br.com.hqhub.service;

import java.time.LocalDateTime;
import java.util.List;
import br.com.hqhub.dto.CadastroHistoriaLeituraDTO;
import br.com.hqhub.dto.HistoriaLeituraRespostaDTO;
import br.com.hqhub.entity.HistoriaLeitura;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.entity.VisualizacaoHistoriaLeitura;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.mapper.UsuarioMapper;
import br.com.hqhub.repository.HistoriaLeituraRepository;
import br.com.hqhub.repository.VisualizacaoHistoriaLeituraRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;
import io.quarkus.scheduler.Scheduled;

@ApplicationScoped
public class HistoriaLeituraService {
    private final HistoriaLeituraRepository historias;
    private final VisualizacaoHistoriaLeituraRepository visualizacoes;
    private final UsuarioAutenticadoService autenticacao;
    private final UsuarioMapper usuarioMapper;
    private final FeedMidiaService midia;

    public HistoriaLeituraService(HistoriaLeituraRepository historias,
            VisualizacaoHistoriaLeituraRepository visualizacoes,
            UsuarioAutenticadoService autenticacao,
            UsuarioMapper usuarioMapper,
            FeedMidiaService midia) {
        this.historias = historias;
        this.visualizacoes = visualizacoes;
        this.autenticacao = autenticacao;
        this.usuarioMapper = usuarioMapper;
        this.midia = midia;
    }

    @Transactional
    public List<HistoriaLeituraRespostaDTO> listar() {
        limparExpiradas();
        Usuario usuario = autenticacao.obterUsuario();
        return historias.listarAtivas(usuario.getId()).stream()
                .map(historia -> paraResposta(historia, usuario.getId()))
                .toList();
    }

    @Transactional
    public HistoriaLeituraRespostaDTO criar(CadastroHistoriaLeituraDTO dto) {
        limparExpiradas();
        Usuario usuario = autenticacao.obterUsuario();
        HistoriaLeitura historia = new HistoriaLeitura();
        historia.setUsuario(usuario);
        historia.setTexto(limpar(dto.texto()));
        historia.setUrlImagem(dto.urlImagem().trim());
        historia.setTituloHq(limpar(dto.tituloHq()));
        historia.setDataExpiracao(LocalDateTime.now().plusHours(24));
        historias.persistAndFlush(historia);
        return paraResposta(historia, usuario.getId());
    }

    @Transactional
    public HistoriaLeituraRespostaDTO visualizar(Long id) {
        Usuario usuario = autenticacao.obterUsuario();
        HistoriaLeitura historia = buscarAtiva(id);
        boolean visivel = historias.listarAtivas(usuario.getId()).stream()
                .anyMatch(item -> item.getId().equals(id));
        if (!visivel) {
            throw new RecursoNaoEncontradoException("História não encontrada.");
        }
        if (!visualizacoes.visualizada(id, usuario.getId())) {
            VisualizacaoHistoriaLeitura visualizacao = new VisualizacaoHistoriaLeitura();
            visualizacao.setHistoria(historia);
            visualizacao.setUsuario(usuario);
            visualizacoes.persist(visualizacao);
        }
        return paraResposta(historia, usuario.getId());
    }

    @Transactional
    public void remover(Long id) {
        Usuario usuario = autenticacao.obterUsuario();
        HistoriaLeitura historia = historias.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("História não encontrada."));
        if (!historia.getUsuario().getId().equals(usuario.getId())) {
            throw new RegraNegocioException("Você não pode excluir esta história.");
        }
        midia.excluirImagemPorUrl(historia.getUrlImagem());
        historias.delete(historia);
    }

    private HistoriaLeitura buscarAtiva(Long id) {
        HistoriaLeitura historia = historias.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("História não encontrada."));
        if (!historia.getDataExpiracao().isAfter(LocalDateTime.now())) {
            throw new RecursoNaoEncontradoException("Esta história expirou.");
        }
        return historia;
    }

    private HistoriaLeituraRespostaDTO paraResposta(HistoriaLeitura historia, Long usuarioId) {
        return new HistoriaLeituraRespostaDTO(
                historia.getId(),
                usuarioMapper.paraResposta(historia.getUsuario()),
                historia.getTexto(),
                historia.getUrlImagem(),
                historia.getTituloHq(),
                visualizacoes.visualizada(historia.getId(), usuarioId),
                visualizacoes.total(historia.getId()),
                historia.getDataCriacao(),
                historia.getDataExpiracao());
    }

    private String limpar(String valor) {
        if (valor == null || valor.isBlank()) return null;
        return valor.trim();
    }

    @Scheduled(every = "1h")
    @Transactional
    public void limparExpiradas() {
        for (HistoriaLeitura historia : historias.listarExpiradas()) {
            midia.excluirImagemPorUrl(historia.getUrlImagem());
            historias.delete(historia);
        }
    }
}
