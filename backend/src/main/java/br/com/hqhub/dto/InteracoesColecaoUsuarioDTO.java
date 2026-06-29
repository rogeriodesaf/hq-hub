package br.com.hqhub.dto;

import java.util.List;

public record InteracoesColecaoUsuarioDTO(
        Long usuarioId,
        InteracaoSocialColecaoDTO colecao,
        List<InteracaoItemColecaoDTO> itens) {
}
