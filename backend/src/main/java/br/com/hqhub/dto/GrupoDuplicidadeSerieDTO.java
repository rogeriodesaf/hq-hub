package br.com.hqhub.dto;

import java.util.List;

public record GrupoDuplicidadeSerieDTO(
        String chave,
        SerieRespostaDTO serieMantida,
        List<SerieRespostaDTO> seriesDescartadas,
        Integer pontuacaoMantida) {
}
