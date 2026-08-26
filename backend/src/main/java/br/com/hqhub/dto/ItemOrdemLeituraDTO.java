package br.com.hqhub.dto;

import br.com.hqhub.entity.StatusIdentificacaoItemOrdem;

public record ItemOrdemLeituraDTO(
        Long id, Integer posicao, String secao, Long edicaoId, Long serieId, String titulo,
        String detalhe, String urlCapa, boolean lido, boolean vinculadoCatalogo,
        boolean naEstante, Long itemColecaoId,
        StatusIdentificacaoItemOrdem statusIdentificacao, String observacao, Integer ano) {
}
