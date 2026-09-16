package br.com.hqhub.dto;

import java.time.LocalDateTime;

public record NotificacaoSocialDTO(
        Long id,
        String tipo,
        UsuarioRespostaDTO autor,
        Long postagemId,
        String mensagem,
        boolean lida,
        LocalDateTime dataCriacao) {
}
