package br.com.hqhub.dto;

public record PessoaComicVineRespostaDTO(
        String idExterno,
        String nome,
        String descricao,
        String descricaoOriginal,
        String dataNascimento,
        String pais,
        String genero,
        String aliases,
        String urlOrigem,
        String urlImagem) {
}
