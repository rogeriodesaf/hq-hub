package br.com.hqhub.dto;

public record FonteExternaRespostaDTO(
        String codigo,
        String nome,
        boolean configurada,
        String observacao) {
}
