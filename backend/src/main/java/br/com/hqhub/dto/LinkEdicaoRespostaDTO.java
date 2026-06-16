package br.com.hqhub.dto;

import java.time.LocalDateTime;

import br.com.hqhub.entity.TipoLinkEdicao;

public record LinkEdicaoRespostaDTO(
        Long id,
        Long edicaoId,
        TipoLinkEdicao tipo,
        String titulo,
        String url,
        String observacoes,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
