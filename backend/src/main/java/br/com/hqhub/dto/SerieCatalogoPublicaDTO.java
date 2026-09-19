package br.com.hqhub.dto;

public record SerieCatalogoPublicaDTO(
        SerieRespostaDTO serie,
        PaginaRespostaDTO<EdicaoRespostaDTO> edicoes) {
}
