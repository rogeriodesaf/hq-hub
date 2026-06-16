package br.com.hqhub.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

import br.com.hqhub.entity.EstadoConservacao;
import br.com.hqhub.entity.StatusLeitura;

public record EstanteEdicaoDTO(
        Long itemColecaoId,
        Long edicaoId,
        String numero,
        String titulo,
        String urlCapa,
        EstadoConservacao estadoConservacao,
        StatusLeitura statusLeitura,
        LocalDate dataAquisicao,
        BigDecimal precoPago) {
}
