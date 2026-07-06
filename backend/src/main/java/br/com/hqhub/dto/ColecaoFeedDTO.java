package br.com.hqhub.dto;

public record ColecaoFeedDTO(
        Long itemColecaoId,
        Long serieId,
        String titulo,
        String editora,
        int quantidadeEdicoes,
        String urlCapa,
        boolean concluida) {
}
