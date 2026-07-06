package br.com.hqhub.exception;

import java.time.LocalDateTime;
import java.util.stream.Collectors;

import org.jboss.logging.Logger;
import org.hibernate.exception.DataException;

import jakarta.persistence.PersistenceException;
import jakarta.validation.ConstraintViolationException;
import jakarta.validation.ValidationException;
import jakarta.ws.rs.WebApplicationException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

@Provider
public class TratadorGlobalException implements ExceptionMapper<Exception> {

    private static final Logger LOG = Logger.getLogger(TratadorGlobalException.class);

    @Override
    public Response toResponse(Exception excecao) {
        if (excecao instanceof RegraNegocioException) {
            return criarResposta(Response.Status.BAD_REQUEST, excecao.getMessage());
        }

        if (excecao instanceof RecursoNaoEncontradoException) {
            return criarResposta(Response.Status.NOT_FOUND, excecao.getMessage());
        }

        if (excecao instanceof ConstraintViolationException violacao) {
            String mensagem = violacao.getConstraintViolations()
                    .stream()
                    .map(item -> item.getMessage())
                    .collect(Collectors.joining(" "));
            return criarResposta(Response.Status.BAD_REQUEST, mensagem);
        }

        if (excecao instanceof ValidationException) {
            return criarResposta(Response.Status.BAD_REQUEST, "Verifique se os dados enviados estão válidos.");
        }

        if (excecao instanceof PersistenceException
            || excecao instanceof org.hibernate.exception.ConstraintViolationException
            || excecao instanceof DataException) {
            return criarResposta(
                Response.Status.BAD_REQUEST,
                "Falha ao salvar os dados no catálogo. " + detalharCausaRaiz(excecao));
        }

        if (excecao instanceof WebApplicationException webApplicationException
                && webApplicationException.getResponse().getStatus() == Response.Status.BAD_REQUEST.getStatusCode()) {
            return criarResposta(Response.Status.BAD_REQUEST,
                    "Não foi possível ler os dados enviados. Verifique se o JSON está válido e em UTF-8.");
        }

        LOG.error("Erro inesperado ao processar requisição.", excecao);
        return criarResposta(Response.Status.INTERNAL_SERVER_ERROR, "Erro interno do servidor.");
    }

    private Response criarResposta(Response.Status status, String mensagem) {
        RespostaErroDTO erro = new RespostaErroDTO(mensagem, status.getStatusCode(), LocalDateTime.now());
        return Response.status(status)
                .entity(erro)
                .build();
    }

    private String detalharCausaRaiz(Throwable excecao) {
        Throwable atual = excecao;
        while (atual.getCause() != null && atual.getCause() != atual) {
            atual = atual.getCause();
        }

        String mensagem = atual.getMessage();
        if (mensagem == null || mensagem.isBlank()) {
            return "Verifique limites de tamanho dos campos, duplicidades e formatos inválidos.";
        }

        String resumida = mensagem.length() > 300 ? mensagem.substring(0, 300) + "..." : mensagem;
        return "Detalhe: " + resumida;
    }
}
