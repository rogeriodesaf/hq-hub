package br.com.hqhub.dto;

import java.util.List;

public record DetalheCatalogoPublicoDTO(
        EdicaoRespostaDTO edicao,
        List<LinkEdicaoRespostaDTO> links) {
}
