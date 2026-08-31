package br.com.hqhub.dto;

import java.util.List;

public record PublicacaoBrasileiraResumoDTO(
        Long id,
        String titulo,
        String numero,
        Integer volume,
        String editora,
        Integer ano,
        String colecao,
        String capa,
        boolean primeiraPublicacao,
        Boolean publicacaoCompleta,
        boolean naEstante,
        int quantidadeHistorias,
        List<HistoriaPublicacaoBrasilDTO> historias) {
}
