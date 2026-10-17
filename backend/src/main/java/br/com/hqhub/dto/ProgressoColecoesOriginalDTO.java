package br.com.hqhub.dto;

import java.time.LocalDate;
import java.util.List;

public record ProgressoColecoesOriginalDTO(
        String idVolumeComicVine,
        String numeroAlvo,
        Double numeroAlvoNumerico,
        List<Colecao> colecoes) {

    public record Colecao(
            Long serieId,
            String titulo,
            Integer volume,
            String editora,
            Long ultimaEdicaoBrasileiraId,
            String ultimaEdicaoBrasileiraNumero,
            LocalDate ultimaPublicacaoBrasileira,
            String ultimaEdicaoOriginalNumero,
            Double ultimaEdicaoOriginalNumerica,
            int edicoesBrasileirasMapeadas,
            int edicoesOriginaisMapeadas,
            double mediaOriginaisPorEdicao,
            Double periodicidadeMediaMeses,
            boolean alvoPublicado,
            boolean colecaoUltrapassouAlvo,
            Integer edicoesOriginaisAteAlvo,
            Integer volumesEstimadosAteAlvo,
            LocalDate previsaoEstimada,
            String confianca) {
    }
}
