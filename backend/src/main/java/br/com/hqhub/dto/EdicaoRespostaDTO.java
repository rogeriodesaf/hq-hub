package br.com.hqhub.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public record EdicaoRespostaDTO(
        Long id,
        String numero,
        String titulo,
        String descricao,
        String descricaoOriginal,
        String descricaoPortugues,
        String descricaoExibicao,
        String nomeVolume,
        LocalDate dataCobertura,
        LocalDate dataDisponibilidadeLoja,
        LocalDate dataPublicacao,
        String urlCapa,
        String codigoBarras,
        Integer quantidadePaginas,
        BigDecimal precoCapa,
        String formato,
        String fonteExterna,
        String idExterno,
        String urlOrigem,
        String urlComicVine,
        String idComicVine,
        SerieResumoDTO serie,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
