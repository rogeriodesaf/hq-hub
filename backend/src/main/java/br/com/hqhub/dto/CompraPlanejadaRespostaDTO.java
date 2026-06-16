package br.com.hqhub.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import br.com.hqhub.entity.PrioridadeCompra;
import br.com.hqhub.entity.StatusCompraPlanejada;

public record CompraPlanejadaRespostaDTO(
        Long id,
        EdicaoRespostaDTO edicao,
        Integer mes,
        Integer ano,
        StatusCompraPlanejada status,
        PrioridadeCompra prioridade,
        BigDecimal precoEstimado,
        String linkCompra,
        String observacoes,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
