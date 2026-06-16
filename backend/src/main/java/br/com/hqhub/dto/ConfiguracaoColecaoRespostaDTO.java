package br.com.hqhub.dto;

import java.time.LocalDateTime;

import br.com.hqhub.entity.VisibilidadeColecao;

public record ConfiguracaoColecaoRespostaDTO(
        Long id,
        VisibilidadeColecao visibilidadeColecao,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
