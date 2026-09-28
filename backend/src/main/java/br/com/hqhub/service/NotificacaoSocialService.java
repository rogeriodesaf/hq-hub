package br.com.hqhub.service;

import java.time.LocalDateTime;
import java.util.List;
import br.com.hqhub.dto.NotificacaoSocialDTO;
import br.com.hqhub.entity.*;
import br.com.hqhub.mapper.UsuarioMapper;
import br.com.hqhub.repository.NotificacaoSocialRepository;
import br.com.hqhub.repository.AmizadeRepository;
import br.com.hqhub.repository.UsuarioRepository;
import io.quarkus.scheduler.Scheduled;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class NotificacaoSocialService {
    private final NotificacaoSocialRepository repository;
    private final UsuarioAutenticadoService autenticacao;
    private final UsuarioMapper usuarioMapper;
    private final UsuarioRepository usuarioRepository;
    private final AmizadeRepository amizadeRepository;

    public NotificacaoSocialService(
            NotificacaoSocialRepository repository,
            UsuarioAutenticadoService autenticacao,
            UsuarioMapper usuarioMapper,
            UsuarioRepository usuarioRepository,
            AmizadeRepository amizadeRepository) {
        this.repository = repository;
        this.autenticacao = autenticacao;
        this.usuarioMapper = usuarioMapper;
        this.usuarioRepository = usuarioRepository;
        this.amizadeRepository = amizadeRepository;
    }

    public List<NotificacaoSocialDTO> listar() {
        Long usuarioId = autenticacao.obterUsuario().getId();
        return repository.listar(usuarioId, LocalDateTime.now().minusDays(30)).stream().map(this::paraDTO).toList();
    }

    public long contarNaoLidas() {
        return repository.contarNaoLidas(autenticacao.obterUsuario().getId());
    }

    @Transactional
    public void marcarTodasComoLidas() {
        repository.update("lida = true, dataVisualizacao = ?1 where destinatario.id = ?2 and lida = false",
                LocalDateTime.now(), autenticacao.obterUsuario().getId());
    }

    @Transactional
    public void marcarComoLida(Long id) {
        repository.update("lida = true, dataVisualizacao = ?1 where id = ?2 and destinatario.id = ?3 and lida = false",
                LocalDateTime.now(), id, autenticacao.obterUsuario().getId());
    }

    public void criar(Usuario destinatario, Usuario autor, TipoNotificacaoSocial tipo, PostagemFeed postagem, ComentarioFeed comentario, String mensagem) {
        if (destinatario.getId().equals(autor.getId())) return;
        if (tipo == TipoNotificacaoSocial.CURTIDA_POSTAGEM
                && repository.existeCurtidaPostagem(destinatario.getId(), autor.getId(), postagem.getId())) return;
        if (tipo == TipoNotificacaoSocial.CURTIDA_COMENTARIO
                && repository.existeCurtidaComentario(destinatario.getId(), autor.getId(), comentario.getId())) return;
        NotificacaoSocial notificacao = new NotificacaoSocial();
        notificacao.setDestinatario(destinatario);
        notificacao.setAutor(autor);
        notificacao.setTipo(tipo);
        notificacao.setPostagem(postagem);
        notificacao.setComentario(comentario);
        notificacao.setMensagem(mensagem);
        repository.persist(notificacao);
    }

    public void notificarNovaPostagemAdministrativa(Usuario autor, PostagemFeed postagem) {
        String mensagem = autor.getNome() + " fez uma nova publicação para a comunidade.";
        usuarioRepository.listarDestinatariosNotificacaoGlobal(autor.getId())
                .forEach(destinatario -> criar(
                        destinatario,
                        autor,
                        TipoNotificacaoSocial.NOVA_POSTAGEM_ADMIN,
                        postagem,
                        null,
                        mensagem));
    }

    public void notificarNovaPostagemDeAmigo(Usuario autor, PostagemFeed postagem) {
        String mensagem = autor.getNome() + " compartilhou uma nova publicação.";
        amizadeRepository.listarAmigos(autor.getId()).stream()
                .map(amizade -> amizade.getSolicitante().getId().equals(autor.getId())
                        ? amizade.getSolicitado()
                        : amizade.getSolicitante())
                .forEach(destinatario -> criar(
                        destinatario,
                        autor,
                        TipoNotificacaoSocial.NOVA_POSTAGEM_AMIGO,
                        postagem,
                        null,
                        mensagem));
    }

    @Scheduled(every = "24h")
    @Transactional
    public void removerNotificacoesVisualizadasAntigas() {
        repository.removerLidasAntesDe(LocalDateTime.now().minusDays(30));
    }

    public void removerCurtidaPostagem(Usuario destinatario, Usuario autor, PostagemFeed postagem) {
        repository.removerCurtidaPostagem(destinatario.getId(), autor.getId(), postagem.getId());
    }

    public void removerCurtidaComentario(Usuario destinatario, Usuario autor, ComentarioFeed comentario) {
        repository.removerCurtidaComentario(destinatario.getId(), autor.getId(), comentario.getId());
    }

    private NotificacaoSocialDTO paraDTO(NotificacaoSocial item) {
        return new NotificacaoSocialDTO(item.getId(), item.getTipo().name(), usuarioMapper.paraResposta(item.getAutor()),
                item.getPostagem() == null ? null : item.getPostagem().getId(), item.getMensagem(), item.isLida(), item.getDataCriacao());
    }
}
