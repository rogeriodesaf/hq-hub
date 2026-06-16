package br.com.hqhub.dto;

public record ResultadoBuscaExternaDTO(
        String fonteExterna,
        String idExterno,
        String tipo,
        String titulo,
        String descricao,
        String urlOrigem,
        String urlImagem) {
}
