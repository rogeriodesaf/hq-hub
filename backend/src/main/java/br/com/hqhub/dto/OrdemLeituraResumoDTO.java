package br.com.hqhub.dto;

public record OrdemLeituraResumoDTO(
        Long id, String slug, String titulo, String descricao, String urlCapa,
        long totalItens, long itensLidos) {
}
