package br.com.hqhub.resource;

import java.sql.SQLException;
import java.sql.SQLTransientException;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import br.com.hqhub.dto.ColetaGuiaRespostaDTO;
import br.com.hqhub.dto.GeracaoRascunhoImportacaoDTO;
import br.com.hqhub.dto.GeracaoRascunhoGcdDTO;
import br.com.hqhub.dto.ImportacaoCatalogoDTO;
import br.com.hqhub.dto.ResultadoBackfillComicVineDTO;
import br.com.hqhub.dto.ResultadoImportacaoCatalogoDTO;
import br.com.hqhub.service.ArmazenamentoImagemService;
import br.com.hqhub.service.ColetaGuiaService;
import br.com.hqhub.service.ColetaGcdService;
import br.com.hqhub.service.GeracaoRascunhoImportacaoService;
import br.com.hqhub.service.ImportacaoCatalogoService;
import org.hibernate.exception.JDBCConnectionException;
import org.hibernate.exception.LockAcquisitionException;
import org.jboss.logging.Logger;
import io.quarkus.security.identity.SecurityIdentity;
import jakarta.annotation.security.RolesAllowed;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.jboss.resteasy.reactive.RestForm;
import org.jboss.resteasy.reactive.multipart.FileUpload;

@Path("/importacoes/catalogo")
@RolesAllowed({ "COLABORADOR", "ADMINISTRADOR" })
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class ImportacaoCatalogoResource {

    private static final Logger LOG = Logger.getLogger(ImportacaoCatalogoResource.class);
    private static final int MAX_TENTATIVAS_IMPORTACAO = 3;
    private static final Set<String> SQL_STATES_TRANSIENTES = Set.of(
            "40001", // serialization_failure
            "40P01", // deadlock_detected (PostgreSQL)
            "55P03", // lock_not_available (PostgreSQL)
            "08001", // sqlclient_unable_to_establish_sqlconnection
            "08006" // connection_failure
    );

    private final ImportacaoCatalogoService importacaoCatalogoService;
    private final GeracaoRascunhoImportacaoService geracaoRascunhoImportacaoService;
    private final ArmazenamentoImagemService armazenamentoImagemService;
    private final ColetaGuiaService coletaGuiaService;
    private final ColetaGcdService coletaGcdService;
    private final SecurityIdentity securityIdentity;

    public ImportacaoCatalogoResource(
            ImportacaoCatalogoService importacaoCatalogoService,
            GeracaoRascunhoImportacaoService geracaoRascunhoImportacaoService,
            ArmazenamentoImagemService armazenamentoImagemService,
            ColetaGuiaService coletaGuiaService,
            ColetaGcdService coletaGcdService,
            SecurityIdentity securityIdentity) {
        this.importacaoCatalogoService = importacaoCatalogoService;
        this.geracaoRascunhoImportacaoService = geracaoRascunhoImportacaoService;
        this.armazenamentoImagemService = armazenamentoImagemService;
        this.coletaGuiaService = coletaGuiaService;
        this.coletaGcdService = coletaGcdService;
        this.securityIdentity = securityIdentity;
    }

    @POST
    public Response importar(
            @Valid ImportacaoCatalogoDTO dto,
            @QueryParam("publicarNovidade") Boolean publicarNovidade) {
        RuntimeException ultimaFalha = null;
        boolean devePublicarNovidade = publicarNovidade == null || publicarNovidade;

        for (int tentativa = 1; tentativa <= MAX_TENTATIVAS_IMPORTACAO; tentativa++) {
            try {
                ResultadoImportacaoCatalogoDTO resultado = importacaoCatalogoService.importar(dto, devePublicarNovidade);
                return Response.ok(resultado).build();
            } catch (RuntimeException excecao) {
                ultimaFalha = excecao;
                if (!ehFalhaTransiente(excecao) || tentativa == MAX_TENTATIVAS_IMPORTACAO) {
                    throw excecao;
                }

                long esperaMs = tentativa * 300L;
                LOG.warnf(
                        "Falha transiente na importacao de catalogo (tentativa %d/%d). Nova tentativa em %dms. Causa: %s",
                        tentativa,
                        MAX_TENTATIVAS_IMPORTACAO,
                        esperaMs,
                        causaRaiz(excecao).getClass().getSimpleName());
                aguardar(esperaMs);
            }
        }

        throw ultimaFalha == null ? new IllegalStateException("Falha inesperada na importacao.") : ultimaFalha;
    }

    @POST
    @Path("/gerar-rascunho")
    public Response gerarRascunho(@Valid GeracaoRascunhoImportacaoDTO dto) {
        ImportacaoCatalogoDTO rascunho = geracaoRascunhoImportacaoService.gerar(dto);
        return Response.ok(rascunho).build();
    }

    @POST
    @Path("/coletas-guia")
    public Response iniciarColetaGuia(@Valid GeracaoRascunhoImportacaoDTO dto) {
        ColetaGuiaRespostaDTO coleta = coletaGuiaService.iniciar(dto);
        return Response.ok(coleta).build();
    }

    @GET
    @Path("/coletas-guia/{id}")
    public Response buscarColetaGuia(@PathParam("id") UUID id) {
        return Response.ok(coletaGuiaService.buscar(id)).build();
    }

    @POST
    @Path("/coletas-guia/{id}/processar")
    public Response processarColetaGuia(@PathParam("id") UUID id) {
        return Response.ok(coletaGuiaService.processarProximaPagina(id)).build();
    }

    @POST
    @Path("/coletas-guia/{id}/retomar")
    public Response retomarColetaGuia(@PathParam("id") UUID id) {
        return Response.ok(coletaGuiaService.retomar(id)).build();
    }

    @GET
    @Path("/gcd/series")
    public Response buscarSeriesGcd(@QueryParam("busca") String busca) {
        return Response.ok(coletaGcdService.buscarSeries(busca)).build();
    }

    @POST
    @Path("/coletas-gcd")
    public Response iniciarColetaGcd(@Valid GeracaoRascunhoGcdDTO dto) {
        return Response.ok(coletaGcdService.iniciar(dto)).build();
    }

    @GET
    @Path("/coletas-gcd/{id}")
    public Response buscarColetaGcd(@PathParam("id") UUID id) {
        return Response.ok(coletaGcdService.buscar(id)).build();
    }

    @POST
    @Path("/coletas-gcd/{id}/processar")
    public Response processarColetaGcd(@PathParam("id") UUID id) {
        return Response.ok(coletaGcdService.processar(id)).build();
    }

    @POST
    @Path("/coletas-gcd/{id}/retomar")
    public Response retomarColetaGcd(@PathParam("id") UUID id) {
        return Response.ok(coletaGcdService.retomar(id)).build();
    }

    @POST
    @Path("/coletas-gcd/{id}/pausar")
    public Response pausarColetaGcd(@PathParam("id") UUID id) {
        return Response.ok(coletaGcdService.pausar(id)).build();
    }

    @POST
    @Path("/coletas-gcd/{id}/finalizar-parcial")
    public Response finalizarColetaGcdParcial(@PathParam("id") UUID id) {
        return Response.ok(coletaGcdService.finalizarParcial(id)).build();
    }

    @POST
    @Path("/capas/upload")
    @Consumes(MediaType.MULTIPART_FORM_DATA)
    public Response enviarCapa(@RestForm("arquivo") FileUpload arquivo) {
        return Response.ok(armazenamentoImagemService.salvarCapa(arquivo)).build();
    }

    @POST
    @Path("/backfill/comic-vine/originais-guia")
    public Response preencherComicVineEdicoesOriginaisGuia(
            @QueryParam("limite") Integer limite,
            @QueryParam("serie") String serie,
            @QueryParam("numero") String numero,
            @QueryParam("serieBrasileiraId") Long serieBrasileiraId,
            @QueryParam("aposId") Long aposId) {
        if (!securityIdentity.hasRole("ADMINISTRADOR")) {
            return Response.status(Response.Status.FORBIDDEN).build();
        }

        try {
            ResultadoBackfillComicVineDTO resultado = importacaoCatalogoService
                    .preencherComicVineEdicoesOriginaisGuia(
                            limite,
                            serie,
                            numero,
                            serieBrasileiraId,
                            aposId);
            return Response.ok(resultado).build();
        } catch (Throwable e) {
            return Response.ok(new ResultadoBackfillComicVineDTO(
                    0,
                    0,
                    0,
                    1,
                    aposId,
                    false,
                    List.of("Falha geral no backfill: " + e.getClass().getSimpleName() + " - " + e.getMessage())))
                    .build();
        }
    }

    private boolean ehFalhaTransiente(Throwable excecao) {
        Throwable raiz = causaRaiz(excecao);

        if (raiz instanceof LockAcquisitionException
                || raiz instanceof JDBCConnectionException
                || raiz instanceof SQLTransientException) {
            return true;
        }

        if (raiz instanceof SQLException sqlException) {
            String sqlState = sqlException.getSQLState();
            if (sqlState != null && SQL_STATES_TRANSIENTES.contains(sqlState)) {
                return true;
            }
        }

        String mensagem = raiz.getMessage();
        if (mensagem == null) {
            return false;
        }

        String mensagemNormalizada = mensagem.toLowerCase();
        return mensagemNormalizada.contains("deadlock")
                || mensagemNormalizada.contains("timeout")
                || mensagemNormalizada.contains("connection reset")
                || mensagemNormalizada.contains("could not obtain lock");
    }

    private Throwable causaRaiz(Throwable excecao) {
        Throwable atual = excecao;
        while (atual.getCause() != null && atual.getCause() != atual) {
            atual = atual.getCause();
        }
        return atual;
    }

    private void aguardar(long milissegundos) {
        try {
            Thread.sleep(milissegundos);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("Thread interrompida durante retentativa de importacao.", e);
        }
    }
}
