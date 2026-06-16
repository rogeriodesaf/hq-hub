package br.com.hqhub.dto;

import br.com.hqhub.entity.EstadoConservacao;

public record EstanteEdicaoDTO(
        Long itemColecaoId,
        Long edicaoId,
        String numero,
        String titulo,
        String urlCapa,
        EstadoConservacao estadoConservacao) {
}
