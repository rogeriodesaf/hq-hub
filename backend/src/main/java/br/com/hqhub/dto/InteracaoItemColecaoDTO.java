package br.com.hqhub.dto;

import java.util.List;

public record InteracaoItemColecaoDTO(
        Long itemColecaoId,
        long totalCurtidas,
        boolean curtidaPeloUsuario,
        List<ComentarioColecaoRespostaDTO> comentarios) {
}
