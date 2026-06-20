package br.com.hqhub.dto;

import java.util.List;

public record ResultadoDeduplicacaoSeriesDTO(
        int gruposAnalisados,
        int gruposMesclados,
        int seriesRemovidas,
        int edicoesMescladas,
        int referenciasAtualizadas,
        List<GrupoDuplicidadeSerieDTO> grupos) {
}
