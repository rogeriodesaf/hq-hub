package br.com.hqhub.dto;

public record ResultadoBuscaConhecimentoDTO(
        Long id,
        String tipo,
        String titulo,
        String conteudo,
        String fonte,
        String urlFonte,
        String confianca,
        Double relevancia) {
}
