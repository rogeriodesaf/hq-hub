package br.com.hqhub.dto;

import java.util.Map;

public record ResultadoNormalizacaoTextoDTO(
        int registrosAfetados,
        int camposCorrigidos,
        Map<String, Integer> camposPorTabela) {
}
