package br.com.hqhub.dto;

public record VolumeComicVineRespostaDTO(
        String idExterno,
        String titulo,
        String editora,
        Integer anoInicio,
        Integer quantidadeEdicoes,
        String descricao,
        String urlOrigem,
        String urlImagem) {
}
