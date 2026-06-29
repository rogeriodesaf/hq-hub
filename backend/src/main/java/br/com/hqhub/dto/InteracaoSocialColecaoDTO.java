package br.com.hqhub.dto;

import java.util.List;

public record InteracaoSocialColecaoDTO(
        long totalCurtidas,
        boolean curtidaPeloUsuario,
        List<ComentarioColecaoRespostaDTO> comentarios) {
}
