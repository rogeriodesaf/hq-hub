package br.com.hqhub.service;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

import java.time.LocalDateTime;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import br.com.hqhub.dto.AutenticacaoUsuarioDTO;
import br.com.hqhub.entity.PerfilUsuario;
import br.com.hqhub.entity.SessaoPersistente;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.repository.SessaoPersistenteRepository;
import br.com.hqhub.repository.UsuarioRepository;

class AutenticacaoServiceTest {
    private UsuarioRepository usuarios;
    private SessaoPersistenteRepository sessoes;
    private TokenService tokens;
    private AutenticacaoService autenticacao;
    private Usuario usuario;

    @BeforeEach
    void preparar() {
        usuarios = mock(UsuarioRepository.class);
        sessoes = mock(SessaoPersistenteRepository.class);
        tokens = mock(TokenService.class);
        autenticacao = new AutenticacaoService(usuarios, tokens, mock(UrlPublicaService.class), sessoes);
        usuario = new Usuario();
        usuario.setId(5L);
        usuario.setNome("Colecionador");
        usuario.setEmail("colecionador@example.com");
        usuario.setSenha("senha-teste");
        usuario.setPerfil(PerfilUsuario.USUARIO);
        when(tokens.gerarToken(usuario)).thenReturn("jwt-curto");
        when(tokens.obterTempoExpiracaoEmSegundos()).thenReturn(86400L);
    }

    @Test
    void loginCriaSessaoPersistenteComTokenAleatorioArmazenadoApenasComoHash() {
        when(usuarios.buscarPorEmail(usuario.getEmail())).thenReturn(Optional.of(usuario));

        var resposta = autenticacao.autenticar(new AutenticacaoUsuarioDTO(usuario.getEmail(), "senha-teste"));

        ArgumentCaptor<SessaoPersistente> captor = ArgumentCaptor.forClass(SessaoPersistente.class);
        verify(sessoes).persist(captor.capture());
        assertEquals(64, captor.getValue().getTokenHash().length());
        assertNotEquals(resposta.refreshToken(), captor.getValue().getTokenHash());
        assertEquals(usuario, captor.getValue().getUsuario());
        assertTrue(captor.getValue().getExpiraEm().isAfter(LocalDateTime.now().plusDays(179)));
        assertEquals("jwt-curto", resposta.token());
    }

    @Test
    void renovacaoTrocaTokenEInvalidaAnterior() {
        SessaoPersistente antiga = new SessaoPersistente();
        antiga.setUsuario(usuario);
        antiga.setExpiraEm(LocalDateTime.now().plusDays(1));
        when(sessoes.findById(anyString())).thenReturn(antiga);

        var resposta = autenticacao.renovar("token-antigo");

        verify(sessoes).delete(antiga);
        verify(sessoes).flush();
        verify(sessoes).persist(any(SessaoPersistente.class));
        assertNotEquals("token-antigo", resposta.refreshToken());
    }

    @Test
    void naoRenovaSessaoExpirada() {
        SessaoPersistente expirada = new SessaoPersistente();
        expirada.setExpiraEm(LocalDateTime.now().minusSeconds(1));
        when(sessoes.findById(anyString())).thenReturn(expirada);

        assertThrows(RegraNegocioException.class, () -> autenticacao.renovar("token-expirado"));
        verify(sessoes, never()).persist(any(SessaoPersistente.class));
    }

    @Test
    void logoutRevogaSessao() {
        autenticacao.sair("token-valido");
        verify(sessoes).deleteById(argThat(hash -> hash.length() == 64));
    }
}
