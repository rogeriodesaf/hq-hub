package br.com.hqhub.service;

import java.time.LocalDateTime;
import java.util.List;
import br.com.hqhub.dto.CadastroHistoriaLeituraDTO;
import br.com.hqhub.dto.HistoriaLeituraRespostaDTO;
import br.com.hqhub.dto.VisualizacaoHistoriaLeituraRespostaDTO;
import br.com.hqhub.dto.CadastroComentarioHistoriaDTO;
import br.com.hqhub.dto.ComentarioHistoriaLeituraDTO;
import br.com.hqhub.entity.HistoriaLeitura;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.entity.VisualizacaoHistoriaLeitura;
import br.com.hqhub.entity.CurtidaHistoriaLeitura;
import br.com.hqhub.entity.ComentarioHistoriaLeitura;
import br.com.hqhub.entity.TipoNotificacaoSocial;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.mapper.UsuarioMapper;
import br.com.hqhub.repository.HistoriaLeituraRepository;
import br.com.hqhub.repository.VisualizacaoHistoriaLeituraRepository;
import br.com.hqhub.repository.CurtidaHistoriaLeituraRepository;
import br.com.hqhub.repository.ComentarioHistoriaLeituraRepository;
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
    private final CurtidaHistoriaLeituraRepository curtidas;
    private final ComentarioHistoriaLeituraRepository comentarios;
    private final NotificacaoSocialService notificacoes;

    public HistoriaLeituraService(HistoriaLeituraRepository historias,
            VisualizacaoHistoriaLeituraRepository visualizacoes,
            UsuarioAutenticadoService autenticacao,
            UsuarioMapper usuarioMapper,
            FeedMidiaService midia, CurtidaHistoriaLeituraRepository curtidas,
            ComentarioHistoriaLeituraRepository comentarios, NotificacaoSocialService notificacoes) {
        this.historias = historias;
        this.visualizacoes = visualizacoes;
        this.autenticacao = autenticacao;
        this.usuarioMapper = usuarioMapper;
        this.midia = midia;
        this.curtidas = curtidas;
        this.comentarios = comentarios;
        this.notificacoes = notificacoes;
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
        if (!historia.getUsuario().getId().equals(usuario.getId())
                && !visualizacoes.visualizada(id, usuario.getId())) {
            VisualizacaoHistoriaLeitura visualizacao = new VisualizacaoHistoriaLeitura();
            visualizacao.setHistoria(historia);
            visualizacao.setUsuario(usuario);
            visualizacoes.persist(visualizacao);
        }
        return paraResposta(historia, usuario.getId());
    }

    @Transactional
    public List<VisualizacaoHistoriaLeituraRespostaDTO> listarVisualizacoes(Long id) {
        Usuario usuario = autenticacao.obterUsuario();
        HistoriaLeitura historia = buscarAtiva(id);
        if (!historia.getUsuario().getId().equals(usuario.getId())) {
            throw new RecursoNaoEncontradoException("História não encontrada.");
        }
        return visualizacoes.listarPorHistoria(id).stream()
                .map(item -> new VisualizacaoHistoriaLeituraRespostaDTO(
                        usuarioMapper.paraResposta(item.getUsuario()),
                        item.getDataVisualizacao()))
                .toList();
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

    @Transactional
    public HistoriaLeituraRespostaDTO alternarCurtida(Long id) {
        Usuario usuario = autenticacao.obterUsuario();
        HistoriaLeitura historia = buscarVisivel(id, usuario);
        var existente = curtidas.buscar(id, usuario.getId());
        if (existente.isPresent()) curtidas.delete(existente.get());
        else {
            CurtidaHistoriaLeitura curtida = new CurtidaHistoriaLeitura();
            curtida.setHistoria(historia); curtida.setUsuario(usuario); curtidas.persist(curtida);
            notificacoes.criar(historia.getUsuario(), usuario, TipoNotificacaoSocial.CURTIDA_HISTORIA, null, null,
                    usuario.getNome() + " curtiu seu story.");
        }
        return paraResposta(historia, usuario.getId());
    }

    @Transactional
    public HistoriaLeituraRespostaDTO comentar(Long id, CadastroComentarioHistoriaDTO dto) {
        Usuario usuario = autenticacao.obterUsuario();
        HistoriaLeitura historia = buscarVisivel(id, usuario);
        ComentarioHistoriaLeitura comentario = new ComentarioHistoriaLeitura();
        comentario.setHistoria(historia); comentario.setUsuario(usuario); comentario.setTexto(dto.texto().trim());
        comentarios.persistAndFlush(comentario);
        notificacoes.criar(historia.getUsuario(), usuario, TipoNotificacaoSocial.COMENTARIO_HISTORIA, null, null,
                usuario.getNome() + " comentou no seu story.");
        return paraResposta(historia, usuario.getId());
    }

    private HistoriaLeitura buscarVisivel(Long id, Usuario usuario) {
        HistoriaLeitura historia = buscarAtiva(id);
        if (historias.listarAtivas(usuario.getId()).stream().noneMatch(item -> item.getId().equals(id)))
            throw new RecursoNaoEncontradoException("História não encontrada.");
        return historia;
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
                curtidas.total(historia.getId()),
                curtidas.buscar(historia.getId(), usuarioId).isPresent(),
                comentarios.listar(historia.getId()).stream()
                        .map(item -> new ComentarioHistoriaLeituraDTO(item.getId(), usuarioMapper.paraResposta(item.getUsuario()), item.getTexto(), item.getDataCriacao()))
                        .toList(),
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
