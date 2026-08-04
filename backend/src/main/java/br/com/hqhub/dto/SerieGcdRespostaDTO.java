package br.com.hqhub.dto;

public record SerieGcdRespostaDTO(
        String apiUrl,
        String nome,
        String pais,
        String idioma,
        Integer anoInicio,
        Integer anoFim,
        Integer totalEdicoes,
        String editora) {
}
