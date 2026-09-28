package br.com.hqhub.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;

import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import br.com.hqhub.entity.Amizade;
import br.com.hqhub.entity.NotificacaoSocial;
import br.com.hqhub.entity.PostagemFeed;
import br.com.hqhub.entity.TipoNotificacaoSocial;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.mapper.UsuarioMapper;
import br.com.hqhub.repository.AmizadeRepository;
import br.com.hqhub.repository.NotificacaoSocialRepository;

class NotificacaoSocialServiceTest {

    @Test
    void distribuiPostagemAdministrativaParaTodosOsUsuarios() {
        NotificacaoSocialRepository notificacoes = mock(NotificacaoSocialRepository.class);
        Usuario autor = usuario(1L, "Coleciona HQ Admin");
        PostagemFeed postagem = postagem(45L, autor);
        NotificacaoSocialService service = service(notificacoes, mock(AmizadeRepository.class));

        service.notificarNovaPostagemAdministrativa(autor, postagem);

        verify(notificacoes).distribuirPostagemAdministrativa(
                1L, 45L, "Coleciona HQ Admin fez uma nova publicação para a comunidade.");
    }

    @Test
    void redistribuiAtualizacaoDePostagemAdministrativa() {
        NotificacaoSocialRepository notificacoes = mock(NotificacaoSocialRepository.class);
        Usuario autor = usuario(1L, "Coleciona HQ Admin");
        PostagemFeed postagem = postagem(45L, autor);
        NotificacaoSocialService service = service(notificacoes, mock(AmizadeRepository.class));

        service.notificarAtualizacaoPostagemAdministrativa(postagem);

        verify(notificacoes).distribuirPostagemAdministrativa(
                1L, 45L, "Coleciona HQ Admin atualizou uma publicação da comunidade.");
    }

    @Test
    void notificaAmigosQuandoUsuarioCompartilhaNovaPostagem() {
        NotificacaoSocialRepository notificacoes = mock(NotificacaoSocialRepository.class);
        AmizadeRepository amizades = mock(AmizadeRepository.class);
        Usuario autor = usuario(1L, "Alex");
        Usuario amigo = usuario(2L, "Bia");
        Amizade amizade = new Amizade();
        amizade.setSolicitante(amigo);
        amizade.setSolicitado(autor);
        PostagemFeed postagem = postagem(50L, autor);
        when(amizades.listarAmigos(autor.getId())).thenReturn(List.of(amizade));

        service(notificacoes, amizades).notificarNovaPostagemDeAmigo(autor, postagem);

        ArgumentCaptor<NotificacaoSocial> captor = ArgumentCaptor.forClass(NotificacaoSocial.class);
        verify(notificacoes).persist(captor.capture());
        assertSame(amigo, captor.getValue().getDestinatario());
        assertSame(autor, captor.getValue().getAutor());
        assertSame(postagem, captor.getValue().getPostagem());
        assertEquals(TipoNotificacaoSocial.NOVA_POSTAGEM_AMIGO, captor.getValue().getTipo());
    }

    @Test
    void removeNotificacaoAssimQueForVisualizada() {
        NotificacaoSocialRepository notificacoes = mock(NotificacaoSocialRepository.class);
        UsuarioAutenticadoService autenticacao = mock(UsuarioAutenticadoService.class);
        when(autenticacao.obterUsuario()).thenReturn(usuario(7L, "Leitor"));
        NotificacaoSocialService service = new NotificacaoSocialService(
                notificacoes, autenticacao, mock(UsuarioMapper.class), mock(AmizadeRepository.class));

        service.marcarComoLida(12L);

        verify(notificacoes).delete("id = ?1 and destinatario.id = ?2", 12L, 7L);
    }

    @Test
    void naoDuplicaNotificacaoDeCurtidaAindaNaoVisualizada() {
        NotificacaoSocialRepository notificacoes = mock(NotificacaoSocialRepository.class);
        Usuario autor = usuario(1L, "Alex");
        Usuario destinatario = usuario(2L, "Bia");
        PostagemFeed postagem = postagem(50L, autor);
        when(notificacoes.existeCurtidaPostagem(destinatario.getId(), autor.getId(), postagem.getId()))
                .thenReturn(true);

        service(notificacoes, mock(AmizadeRepository.class)).criar(
                destinatario, autor, TipoNotificacaoSocial.CURTIDA_POSTAGEM,
                postagem, null, "Alex curtiu sua publicação.");

        verify(notificacoes, never()).persist(org.mockito.ArgumentMatchers.any(NotificacaoSocial.class));
    }

    private NotificacaoSocialService service(
            NotificacaoSocialRepository notificacoes, AmizadeRepository amizades) {
        return new NotificacaoSocialService(
                notificacoes,
                mock(UsuarioAutenticadoService.class),
                mock(UsuarioMapper.class),
                amizades);
    }

    private PostagemFeed postagem(Long id, Usuario autor) {
        PostagemFeed postagem = new PostagemFeed();
        postagem.setId(id);
        postagem.setUsuario(autor);
        return postagem;
    }

    private Usuario usuario(Long id, String nome) {
        Usuario usuario = new Usuario();
        usuario.setId(id);
        usuario.setNome(nome);
        return usuario;
    }
}
