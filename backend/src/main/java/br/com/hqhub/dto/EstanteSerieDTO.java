package br.com.hqhub.dto;

import java.util.List;

public record EstanteSerieDTO(
        Long serieId,
        String titulo,
        List<EstanteEdicaoDTO> edicoes) {
}
