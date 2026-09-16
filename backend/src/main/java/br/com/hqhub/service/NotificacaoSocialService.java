package br.com.hqhub.service;

import java.util.List;
import br.com.hqhub.dto.NotificacaoSocialDTO;
import br.com.hqhub.entity.*;
import br.com.hqhub.mapper.UsuarioMapper;
import br.com.hqhub.repository.NotificacaoSocialRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class NotificacaoSocialService {
    private final NotificacaoSocialRepository repository;
    private final UsuarioAutenticadoService autenticacao;
    private final UsuarioMapper usuarioMapper;

    public NotificacaoSocialService(NotificacaoSocialRepository repository, UsuarioAutenticadoService autenticacao, UsuarioMapper usuarioMapper) {
        this.repository = repository;
        this.autenticacao = autenticacao;
        this.usuarioMapper = usuarioMapper;
    }

    public List<NotificacaoSocialDTO> listar() {
        Long usuarioId = autenticacao.obterUsuario().getId();
        return repository.listar(usuarioId).stream().map(this::paraDTO).toList();
    }

    public long contarNaoLidas() {
        return repository.contarNaoLidas(autenticacao.obterUsuario().getId());
    }

    @Transactional
    public void marcarTodasComoLidas() {
        repository.update("lida = true where destinatario.id = ?1", autenticacao.obterUsuario().getId());
    }

    public void criar(Usuario destinatario, Usuario autor, TipoNotificacaoSocial tipo, PostagemFeed postagem, ComentarioFeed comentario, String mensagem) {
        if (destinatario.getId().equals(autor.getId())) return;
        NotificacaoSocial notificacao = new NotificacaoSocial();
        notificacao.setDestinatario(destinatario);
        notificacao.setAutor(autor);
        notificacao.setTipo(tipo);
        notificacao.setPostagem(postagem);
        notificacao.setComentario(comentario);
        notificacao.setMensagem(mensagem);
        repository.persist(notificacao);
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
