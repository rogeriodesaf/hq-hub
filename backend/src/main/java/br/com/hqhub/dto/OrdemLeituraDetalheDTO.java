package br.com.hqhub.dto;

import java.util.List;

public record OrdemLeituraDetalheDTO(
        Long id, String slug, String titulo, String descricao,
        long totalItens, long itensLidos, List<ItemOrdemLeituraDTO> itens) {
}
