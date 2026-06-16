package br.com.hqhub.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public record EdicaoRespostaDTO(
        Long id,
        String numero,
        String titulo,
        String descricao,
        LocalDate dataPublicacao,
        String urlCapa,
        String codigoBarras,
        Integer quantidadePaginas,
        BigDecimal precoCapa,
        String fonteExterna,
        String idExterno,
        String urlOrigem,
        SerieResumoDTO serie,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
