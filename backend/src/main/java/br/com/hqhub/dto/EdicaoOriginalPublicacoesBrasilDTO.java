package br.com.hqhub.dto;

public record EdicaoOriginalPublicacoesBrasilDTO(
        Long id,
        String titulo,
        String numero,
        Integer volume,
        String editora,
        Integer ano,
        String pais,
        String capa) {
}
