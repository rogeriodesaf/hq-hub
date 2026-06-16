package br.com.hqhub.dto;

import java.time.LocalDateTime;

import br.com.hqhub.entity.StatusColecaoSerie;

public record ColecaoSerieRespostaDTO(
        Long id,
        SerieResumoDTO serie,
        StatusColecaoSerie status,
        Integer prioridade,
        String observacoes,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
