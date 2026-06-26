package br.com.hqhub.exception;

import java.time.LocalDateTime;
import java.util.stream.Collectors;

import org.jboss.logging.Logger;

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
}
