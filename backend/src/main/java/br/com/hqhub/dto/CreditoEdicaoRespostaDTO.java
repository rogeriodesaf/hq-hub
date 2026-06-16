package br.com.hqhub.dto;

import br.com.hqhub.entity.PapelCriador;

public record CreditoEdicaoRespostaDTO(
        Long id,
        CriadorRespostaDTO criador,
        EdicaoRespostaDTO edicao,
        PapelCriador papel,
        String observacoes) {
}
