package br.com.hqhub.service;

import br.com.hqhub.dto.RedefinicaoSenhaDTO;
import br.com.hqhub.dto.SolicitacaoRedefinicaoSenhaDTO;
import br.com.hqhub.entity.TokenRedefinicaoSenha;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.repository.SessaoPersistenteRepository;
import br.com.hqhub.repository.TokenRedefinicaoSenhaRepository;
import br.com.hqhub.repository.UsuarioRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.util.HexFormat;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class RedefinicaoSenhaServiceTest {
    private UsuarioRepository usuarios;
    private TokenRedefinicaoSenhaRepository tokens;
    private SessaoPersistenteRepository sessoes;
    private EmailRedefinicaoSenhaService email;
    private RedefinicaoSenhaService servico;
    private Usuario usuario;

    @BeforeEach
    void preparar() {
        usuarios = mock(UsuarioRepository.class);
        tokens = mock(TokenRedefinicaoSenhaRepository.class);
        sessoes = mock(SessaoPersistenteRepository.class);
        email = mock(EmailRedefinicaoSenhaService.class);
        when(email.configurado()).thenReturn(true);
        servico = new RedefinicaoSenhaService(usuarios, tokens, sessoes, email, "https://hqhub.space");
        usuario = new Usuario();
        usuario.setEmail("leitor@example.com");
        usuario.setSenha("senha-antiga");
    }

    @Test
    void criaLinkSeguroTemporarioNoDominioCorretoSemPersistirTokenBruto() throws Exception {
        when(usuarios.buscarPorEmail("leitor@example.com")).thenReturn(Optional.of(usuario));
        servico.solicitar(new SolicitacaoRedefinicaoSenhaDTO("Leitor@Example.com"));
        ArgumentCaptor<TokenRedefinicaoSenha> entidade = ArgumentCaptor.forClass(TokenRedefinicaoSenha.class);
        ArgumentCaptor<String> html = ArgumentCaptor.forClass(String.class);
        verify(tokens).persist(entidade.capture());
        verify(email).enviar(eq("leitor@example.com"), html.capture());
        Matcher matcher = Pattern.compile("https://hqhub.space/#/entrar\\?token=([A-Za-z0-9_-]+)").matcher(html.getValue());
        assertTrue(matcher.find());
        String recebido = matcher.group(1);
        assertTrue(recebido.length() >= 43);
        String hash = HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256")
                .digest(recebido.getBytes(StandardCharsets.UTF_8)));
        assertEquals(hash, entidade.getValue().getToken());
        assertTrue(entidade.getValue().getExpiraEm().isAfter(LocalDateTime.now().plusMinutes(59)));
    }

    @Test
    void enderecoInexistenteNaoCriaTokenNemEnviaEmail() {
        servico.solicitar(new SolicitacaoRedefinicaoSenhaDTO("ausente@example.com"));
        verify(tokens, never()).persist(any(TokenRedefinicaoSenha.class));
        verify(email, never()).enviar(anyString(), anyString());
    }

    @Test
    void falhaNoEnvioPropagaParaRollbackTransacional() {
        when(usuarios.buscarPorEmail("leitor@example.com")).thenReturn(Optional.of(usuario));
        doThrow(new IllegalStateException("falha")).when(email).enviar(anyString(), anyString());
        assertThrows(IllegalStateException.class,
                () -> servico.solicitar(new SolicitacaoRedefinicaoSenhaDTO("leitor@example.com")));
    }

    @Test
    void cooldownImpedeReenvioEExcessoDeSolicitacoes() {
        when(usuarios.buscarPorEmail("leitor@example.com")).thenReturn(Optional.of(usuario));
        when(tokens.existeRecentePorUsuario(eq(usuario), any())).thenReturn(true);
        for (int i = 0; i < 5; i++)
            servico.solicitar(new SolicitacaoRedefinicaoSenhaDTO("leitor@example.com"));
        verify(usuarios, times(3)).buscarPorEmail("leitor@example.com");
        verify(email, never()).enviar(anyString(), anyString());
    }

    @Test
    void tokenExpiradoNaoAlteraSenhaNemRevogaSessao() {
        TokenRedefinicaoSenha entidade = new TokenRedefinicaoSenha();
        entidade.setUsuario(usuario);
        entidade.setExpiraEm(LocalDateTime.now().minusSeconds(1));
        when(tokens.buscarPorTokenParaConsumo(anyString())).thenReturn(Optional.of(entidade));
        assertThrows(RegraNegocioException.class,
                () -> servico.redefinir(new RedefinicaoSenhaDTO("token-expirado", "nova-senha")));
        assertEquals("senha-antiga", usuario.getSenha());
        verify(sessoes, never()).revogarPorUsuario(any());
    }

    @Test
    void tokenValidoEhConsumidoUmaVezERevogaSessoes() {
        TokenRedefinicaoSenha entidade = new TokenRedefinicaoSenha();
        entidade.setUsuario(usuario);
        entidade.setExpiraEm(LocalDateTime.now().plusMinutes(5));
        when(tokens.buscarPorTokenParaConsumo(anyString()))
                .thenReturn(Optional.of(entidade)).thenReturn(Optional.empty());
        servico.redefinir(new RedefinicaoSenhaDTO("token-valido", "nova-senha"));
        assertNotEquals("senha-antiga", usuario.getSenha());
        verify(tokens).delete(entidade);
        verify(sessoes).revogarPorUsuario(usuario);
        assertThrows(RegraNegocioException.class,
                () -> servico.redefinir(new RedefinicaoSenhaDTO("token-valido", "outra-senha")));
    }
}
