package br.com.hqhub.dto;

import java.util.List;

public record GrupoDuplicidadeEdicaoDTO(
        String chave,
        EdicaoRespostaDTO edicaoMantida,
        List<EdicaoRespostaDTO> edicoesDescartadas,
        Integer pontuacaoMantida) {
}
