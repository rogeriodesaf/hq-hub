package br.com.hqhub.dto;

public record ItemOrdemLeituraDTO(
        Long id, Integer posicao, Long edicaoId, Long serieId, String titulo,
        String detalhe, String urlCapa, boolean lido, boolean vinculadoCatalogo) {
}
