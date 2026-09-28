package br.com.hqhub.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;

import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import br.com.hqhub.entity.NotificacaoSocial;
import br.com.hqhub.entity.Amizade;
import br.com.hqhub.entity.PostagemFeed;
import br.com.hqhub.entity.TipoNotificacaoSocial;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.mapper.UsuarioMapper;
import br.com.hqhub.repository.NotificacaoSocialRepository;
import br.com.hqhub.repository.AmizadeRepository;
import br.com.hqhub.repository.UsuarioRepository;

class NotificacaoSocialServiceTest {

    @Test
    void notificaTodosOsUsuariosExcetoOAutorDaPostagemAdministrativa() {
        NotificacaoSocialRepository notificacoes = mock(NotificacaoSocialRepository.class);
        UsuarioRepository usuarios = mock(UsuarioRepository.class);
        Usuario autor = usuario(1L, "Coleciona HQ Admin");
        Usuario primeiro = usuario(2L, "Primeiro leitor");
        Usuario segundo = usuario(3L, "Segundo leitor");
        PostagemFeed postagem = new PostagemFeed();
        postagem.setId(45L);
        postagem.setUsuario(autor);
        when(usuarios.listarDestinatariosNotificacaoGlobal(autor.getId()))
                .thenReturn(List.of(primeiro, segundo));

        NotificacaoSocialService service = new NotificacaoSocialService(
                notificacoes,
                mock(UsuarioAutenticadoService.class),
                mock(UsuarioMapper.class),
                usuarios,
                mock(AmizadeRepository.class));
        service.notificarNovaPostagemAdministrativa(autor, postagem);

        ArgumentCaptor<NotificacaoSocial> captor = ArgumentCaptor.forClass(NotificacaoSocial.class);
        verify(notificacoes, times(2)).persist(captor.capture());
        assertEquals(List.of(primeiro, segundo),
                captor.getAllValues().stream().map(NotificacaoSocial::getDestinatario).toList());
        captor.getAllValues().forEach(item -> {
            assertSame(autor, item.getAutor());
            assertSame(postagem, item.getPostagem());
            assertEquals(TipoNotificacaoSocial.NOVA_POSTAGEM_ADMIN, item.getTipo());
            assertEquals("Coleciona HQ Admin fez uma nova publicação para a comunidade.", item.getMensagem());
        });
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
        PostagemFeed postagem = new PostagemFeed();
        postagem.setId(50L);
        postagem.setUsuario(autor);
        when(amizades.listarAmigos(autor.getId())).thenReturn(List.of(amizade));

        NotificacaoSocialService service = new NotificacaoSocialService(
                notificacoes,
                mock(UsuarioAutenticadoService.class),
                mock(UsuarioMapper.class),
                mock(UsuarioRepository.class),
                amizades);
        service.notificarNovaPostagemDeAmigo(autor, postagem);

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
                notificacoes,
                autenticacao,
                mock(UsuarioMapper.class),
                mock(UsuarioRepository.class),
                mock(AmizadeRepository.class));

        service.marcarComoLida(12L);

        verify(notificacoes).delete("id = ?1 and destinatario.id = ?2", 12L, 7L);
    }

    @Test
    void naoDuplicaNotificacaoDeCurtidaAindaNaoVisualizada() {
        NotificacaoSocialRepository notificacoes = mock(NotificacaoSocialRepository.class);
        Usuario autor = usuario(1L, "Alex");
        Usuario destinatario = usuario(2L, "Bia");
        PostagemFeed postagem = new PostagemFeed();
        postagem.setId(50L);
        when(notificacoes.existeCurtidaPostagem(destinatario.getId(), autor.getId(), postagem.getId()))
                .thenReturn(true);
        NotificacaoSocialService service = new NotificacaoSocialService(
                notificacoes,
                mock(UsuarioAutenticadoService.class),
                mock(UsuarioMapper.class),
                mock(UsuarioRepository.class),
                mock(AmizadeRepository.class));

        service.criar(destinatario, autor, TipoNotificacaoSocial.CURTIDA_POSTAGEM,
                postagem, null, "Alex curtiu sua publicação.");

        verify(notificacoes, never()).persist(org.mockito.ArgumentMatchers.any(NotificacaoSocial.class));
    }

    private Usuario usuario(Long id, String nome) {
        Usuario usuario = new Usuario();
        usuario.setId(id);
        usuario.setNome(nome);
        return usuario;
    }
}
