package br.com.hqhub.dto;

import java.util.List;

public record RespostaBuscaExternaDTO(
        String fonteExterna,
        String termo,
        List<ResultadoBuscaExternaDTO> resultados) {
}
