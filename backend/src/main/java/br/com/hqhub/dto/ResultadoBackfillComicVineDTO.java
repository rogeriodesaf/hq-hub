package br.com.hqhub.dto;

import java.util.List;

public record ResultadoBackfillComicVineDTO(
        int processadas,
        int atualizadas,
        int semCorrespondencia,
        Long proximoCursor,
        boolean possuiMais,
        List<String> avisos) {
}
