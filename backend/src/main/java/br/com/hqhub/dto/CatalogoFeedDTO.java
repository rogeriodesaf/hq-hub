package br.com.hqhub.dto;

public record CatalogoFeedDTO(
        Long serieId,
        String titulo,
        String editora,
        int quantidadeEdicoes,
        String urlCapa) {
}
