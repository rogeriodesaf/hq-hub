package br.com.hqhub.dto;

import br.com.hqhub.entity.TipoRelacionamentoSerie;

public record RelacionamentoSerieRespostaDTO(
        Long id,
        SerieResumoDTO serieOrigem,
        SerieResumoDTO serieDestino,
        TipoRelacionamentoSerie tipo,
        String observacoes) {
}
