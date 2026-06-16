package br.com.hqhub.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

import br.com.hqhub.entity.EstadoConservacao;
import br.com.hqhub.entity.StatusLeitura;

public record ItemColecaoRespostaDTO(
        Long id,
        EdicaoRespostaDTO edicao,
        EstadoConservacao estadoConservacao,
        LocalDate dataAquisicao,
        BigDecimal precoPago,
        StatusLeitura statusLeitura,
        String observacoes,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
