package br.com.hqhub.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.quarkus.mailer.Mailer;
import org.junit.jupiter.api.Test;

import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class EmailRedefinicaoSenhaServiceTest {
    @Test
    void usaSmtpExistenteQuandoHttpsNaoConfigurado() {
        Mailer mailer = mock(Mailer.class);
        var servico = new EmailRedefinicaoSenhaService(mailer, new ObjectMapper(),
                "__NAO_CONFIGURADO__", "__NAO_CONFIGURADO__", "usuario", "senha", mock(HttpClient.class));
        assertTrue(servico.configurado());
        servico.enviar("leitor@example.com", "<p>mensagem</p>");
        verify(mailer).send(any(io.quarkus.mailer.Mail.class));
    }

    @Test
    @SuppressWarnings({"unchecked", "rawtypes"})
    void usaHttpsERejeitaFalhaSemExporResposta() throws Exception {
        HttpClient http = mock(HttpClient.class);
        HttpResponse<Void> resposta = mock(HttpResponse.class);
        when(resposta.statusCode()).thenReturn(202, 401);
        doReturn(resposta).when(http).send(any(HttpRequest.class), any(HttpResponse.BodyHandler.class));
        var servico = new EmailRedefinicaoSenhaService(mock(Mailer.class), new ObjectMapper(),
                "chave-teste", "Coleciona HQ <noreply@hqhub.space>",
                "__NAO_CONFIGURADO__", "__NAO_CONFIGURADO__", http);
        assertTrue(servico.configurado());
        assertDoesNotThrow(() -> servico.enviar("leitor@example.com", "<p>mensagem</p>"));
        assertThrows(IllegalStateException.class,
                () -> servico.enviar("leitor@example.com", "<p>mensagem</p>"));
    }

    @Test
    void rejeitaFaltaDeConfiguracao() {
        var servico = new EmailRedefinicaoSenhaService(mock(Mailer.class), new ObjectMapper(),
                "__NAO_CONFIGURADO__", "__NAO_CONFIGURADO__",
                "__NAO_CONFIGURADO__", "__NAO_CONFIGURADO__", mock(HttpClient.class));
        assertFalse(servico.configurado());
    }
}
