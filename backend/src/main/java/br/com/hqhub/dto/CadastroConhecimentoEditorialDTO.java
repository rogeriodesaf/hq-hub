package br.com.hqhub.dto;

public record CadastroConhecimentoEditorialDTO(
        String tipo,
        String titulo,
        String conteudo,
        String fonte,
        String urlFonte,
        String confianca,
        String origemDados,
        String tags) {
}
