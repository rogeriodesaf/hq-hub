package br.com.hqhub.service;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.stream.StreamSupport;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import br.com.hqhub.dto.CalculoInflacaoRespostaDTO;
import br.com.hqhub.exception.RegraNegocioException;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class CalculadoraInflacaoService {

    private static final DateTimeFormatter FORMATO_BCB = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final Duration TEMPO_LIMITE_CONEXAO = Duration.ofSeconds(5);
    private static final Duration TEMPO_LIMITE_REQUISICAO = Duration.ofSeconds(15);
    private static final MathContext CONTEXTO_CALCULO = new MathContext(12, RoundingMode.HALF_UP);

    private final HttpClient httpClient;
    private final ObjectMapper objectMapper;

    public CalculadoraInflacaoService(ObjectMapper objectMapper) {
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(TEMPO_LIMITE_CONEXAO)
                .build();
        this.objectMapper = objectMapper;
    }

    public CalculoInflacaoRespostaDTO calcular(BigDecimal valorOriginal, LocalDate dataReferencia) {
        if (valorOriginal == null || valorOriginal.compareTo(BigDecimal.ZERO) <= 0) {
            throw new RegraNegocioException("Valor original deve ser maior que zero.");
        }

        if (dataReferencia == null) {
            throw new RegraNegocioException("Data de referência é obrigatória.");
        }

        LocalDate dataCalculo = LocalDate.now();
        if (dataReferencia.isAfter(dataCalculo)) {
            throw new RegraNegocioException("Data de referência não pode ser futura.");
        }

        BigDecimal fator = buscarFatorIpca(dataReferencia, dataCalculo);
        BigDecimal valorCorrigido = valorOriginal.multiply(fator, CONTEXTO_CALCULO).setScale(2, RoundingMode.HALF_UP);
        BigDecimal percentual = fator.subtract(BigDecimal.ONE)
                .multiply(BigDecimal.valueOf(100), CONTEXTO_CALCULO)
                .setScale(2, RoundingMode.HALF_UP);

        return new CalculoInflacaoRespostaDTO(
                valorOriginal.setScale(2, RoundingMode.HALF_UP),
                valorCorrigido,
                fator.setScale(6, RoundingMode.HALF_UP),
                percentual,
                dataReferencia,
                dataCalculo,
                "IPCA/IBGE via Banco Central do Brasil",
                "Cálculo estimado com a série mensal 433 do SGS/BCB.");
    }

    private BigDecimal buscarFatorIpca(LocalDate dataReferencia, LocalDate dataCalculo) {
        LocalDate inicio = dataReferencia.withDayOfMonth(1);
        LocalDate fim = dataCalculo.withDayOfMonth(1);
        String url = "https://api.bcb.gov.br/dados/serie/bcdata.sgs.433/dados?formato=json"
                + "&dataInicial=" + codificar(inicio.format(FORMATO_BCB))
                + "&dataFinal=" + codificar(fim.format(FORMATO_BCB));

        JsonNode raiz = executarGet(url);
        BigDecimal fator = BigDecimal.ONE;

        for (JsonNode ponto : StreamSupport.stream(raiz.spliterator(), false).toList()) {
            BigDecimal variacaoMensal = new BigDecimal(ponto.path("valor").asText("0").replace(",", "."));
            BigDecimal fatorMensal = BigDecimal.ONE.add(variacaoMensal.divide(BigDecimal.valueOf(100), CONTEXTO_CALCULO));
            fator = fator.multiply(fatorMensal, CONTEXTO_CALCULO);
        }

        return fator;
    }

    private JsonNode executarGet(String url) {
        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .timeout(TEMPO_LIMITE_REQUISICAO)
                    .header("Accept", "application/json")
                    .header("User-Agent", "HQ-HUB/1.0")
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                throw new RegraNegocioException("Não foi possível consultar o índice de inflação agora.");
            }

            return objectMapper.readTree(response.body());
        } catch (IOException e) {
            throw new RegraNegocioException("Não foi possível consultar o índice de inflação agora.");
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RegraNegocioException("Consulta ao índice de inflação foi interrompida.");
        }
    }

    private String codificar(String valor) {
        return URLEncoder.encode(valor, StandardCharsets.UTF_8);
    }
}
