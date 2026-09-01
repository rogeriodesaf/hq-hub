package br.com.hqhub.dto;

public record PublicacaoRelacionadaGuiaDTO(
        Long id,
        String titulo,
        String detalhe,
        String urlCapa,
        Integer ano) {
}
