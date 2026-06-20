package br.com.hqhub.dto;

import java.util.List;

import br.com.hqhub.entity.VisibilidadeColecao;

public record ColecaoCompartilhadaRespostaDTO(
        UsuarioRespostaDTO usuario,
        VisibilidadeColecao visibilidadeColecao,
        boolean exibirValorColecao,
        List<ItemColecaoRespostaDTO> itens) {
}
