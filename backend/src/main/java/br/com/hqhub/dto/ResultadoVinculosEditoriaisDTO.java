package br.com.hqhub.dto;

import java.util.List;

public record ResultadoVinculosEditoriaisDTO(
        int processadas,
        int vinculadas,
        int jaVinculadas,
        int semVinculoConfirmado,
        int falhas,
        boolean possuiMais,
        List<String> avisos) {
}
