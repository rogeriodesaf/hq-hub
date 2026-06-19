package br.com.hqhub.dto;

import java.util.List;

public record ResultadoImportacaoCatalogoDTO(
        Long serieId,
        String serieTitulo,
        int editorasCriadas,
        int seriesCriadas,
        int edicoesCriadas,
        int edicoesAtualizadas,
        int historiasCriadas,
        int conteudosCriados,
        int publicacoesCriadas,
        int itensReaproveitados,
        List<String> avisos) {
}
