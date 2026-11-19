package br.com.hqhub.resource;

import br.com.hqhub.dto.SolicitacaoRedefinicaoSenhaDTO;
import br.com.hqhub.service.AutenticacaoService;
import br.com.hqhub.service.RedefinicaoSenhaService;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.*;

class AutenticacaoResourceRedefinicaoTest {
    @Test
    void respostaNaoDistingueEnderecoInexistenteDeFalhaDeEnvio() {
        RedefinicaoSenhaService servico = mock(RedefinicaoSenhaService.class);
        AutenticacaoResource resource = new AutenticacaoResource(mock(AutenticacaoService.class), servico);
        var dto = new SolicitacaoRedefinicaoSenhaDTO("teste@example.com");
        assertEquals(200, resource.solicitarRedefinicao(dto).getStatus());
        doThrow(new IllegalStateException("falha SMTP")).when(servico).solicitar(dto);
        assertEquals(200, resource.solicitarRedefinicao(dto).getStatus());
    }
}
