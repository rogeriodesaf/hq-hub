package br.com.hqhub.dto;

import java.util.List;

public record ResultadoDeduplicacaoEdicoesDTO(
        int gruposAnalisados,
        int gruposMesclados,
        int edicoesRemovidas,
        int referenciasAtualizadas,
        List<GrupoDuplicidadeEdicaoDTO> grupos) {
}
