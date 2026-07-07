package br.com.hqhub.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

import br.com.hqhub.entity.TipoLinkEdicao;

public record LinkEdicaoRespostaDTO(
        Long id,
        Long edicaoId,
        TipoLinkEdicao tipo,
        String titulo,
        String url,
        String observacoes,
        BigDecimal preco,
        LocalDate dataCapturacaoPreco,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
