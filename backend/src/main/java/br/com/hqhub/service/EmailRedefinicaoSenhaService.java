package br.com.hqhub.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.quarkus.mailer.Mail;
import io.quarkus.mailer.Mailer;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.List;
import java.util.Map;

@ApplicationScoped
public class EmailRedefinicaoSenhaService {
    private final Mailer mailer;
    private final ObjectMapper mapper;
    private final String resendKey;
    private final String remetente;
    private final String smtpUsuario;
    private final String smtpSenha;
    private final HttpClient http;

    @Inject
    public EmailRedefinicaoSenhaService(Mailer mailer, ObjectMapper mapper,
            @ConfigProperty(name = "hqhub.resend.api-key") String resendKey,
            @ConfigProperty(name = "hqhub.mail.from") String remetente,
            @ConfigProperty(name = "hqhub.smtp.usuario") String smtpUsuario,
            @ConfigProperty(name = "hqhub.smtp.senha") String smtpSenha) {
        this(mailer, mapper, resendKey, remetente, smtpUsuario, smtpSenha,
                HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(8)).build());
    }

    EmailRedefinicaoSenhaService(Mailer mailer, ObjectMapper mapper, String resendKey,
            String remetente, String smtpUsuario, String smtpSenha, HttpClient http) {
        this.mailer = mailer;
        this.mapper = mapper;
        this.resendKey = resendKey;
        this.remetente = remetente;
        this.smtpUsuario = smtpUsuario;
        this.smtpSenha = smtpSenha;
        this.http = http;
    }

    public boolean configurado() {
        return (valido(resendKey) && valido(remetente))
                || (valido(smtpUsuario) && valido(smtpSenha));
    }

    public void enviar(String destinatario, String html) {
        if (valido(resendKey) && valido(remetente)) enviarPorHttps(destinatario, html);
        else {
            try {
                mailer.send(Mail.withHtml(destinatario, "Redefinição de senha - Coleciona HQ", html));
            } catch (RuntimeException excecao) {
                throw new Falha("SMTP_FALHOU");
            }
        }
    }

    private void enviarPorHttps(String destinatario, String html) {
        try {
            String corpo = mapper.writeValueAsString(Map.of(
                    "from", remetente, "to", List.of(destinatario),
                    "subject", "Redefinição de senha - Coleciona HQ", "html", html));
            HttpRequest pedido = HttpRequest.newBuilder(URI.create("https://api.resend.com/emails"))
                    .timeout(Duration.ofSeconds(12))
                    .header("Authorization", "Bearer " + resendKey)
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(corpo)).build();
            HttpResponse<Void> resposta = http.send(pedido, HttpResponse.BodyHandlers.discarding());
            int status = resposta.statusCode();
            if (status < 200 || status >= 300)
                throw new Falha("HTTPS_STATUS_" + status);
        } catch (JsonProcessingException excecao) {
            throw new Falha("HTTPS_SERIALIZACAO");
        } catch (IOException excecao) {
            throw new Falha("HTTPS_CONEXAO");
        } catch (InterruptedException excecao) {
            Thread.currentThread().interrupt();
            throw new Falha("HTTPS_INTERROMPIDO");
        }
    }

    private boolean valido(String valor) {
        return valor != null && !valor.isBlank() && !"__NAO_CONFIGURADO__".equals(valor);
    }

    public static final class Falha extends IllegalStateException {
        private final String codigo;

        public Falha(String codigo) {
            super(codigo);
            this.codigo = codigo;
        }

        public String codigo() {
            return codigo;
        }
    }
}
