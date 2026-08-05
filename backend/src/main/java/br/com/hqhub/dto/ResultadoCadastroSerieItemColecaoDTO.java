package br.com.hqhub.dto;

public record ResultadoCadastroSerieItemColecaoDTO(
        Long serieId,
        String tituloSerie,
        int totalEdicoes,
        int adicionadas,
        int jaExistentes) {
}
