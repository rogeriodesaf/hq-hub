package br.com.hqhub.dto;

import java.util.List;

import br.com.hqhub.entity.TipoAtividadeEstante;

public record AtividadeEstanteDTO(
        TipoAtividadeEstante tipo,
        int quantidade,
        List<EdicaoAtividadeEstanteDTO> edicoes) {
}
