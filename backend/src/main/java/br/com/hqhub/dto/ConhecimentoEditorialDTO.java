package br.com.hqhub.dto;

import java.time.LocalDateTime;

public record ConhecimentoEditorialDTO(
        Long id,
        String tipo,
        String titulo,
        String conteudo,
        String fonte,
        String urlFonte,
        String confianca,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao,
        String origemDados,
        String tags,
        String relacionadas) {
}

record CadastroConhecimentoEditorialDTO(
        String tipo,
        String titulo,
        String conteudo,
        String fonte,
        String urlFonte,
        String confianca,
        String origemDados,
        String tags) {
}

record ResultadoBuscaConhecimentoDTO(
        Long id,
        String tipo,
        String titulo,
        String conteudo,
        String fonte,
        String urlFonte,
        String confianca,
        Double relevancia) {
}
