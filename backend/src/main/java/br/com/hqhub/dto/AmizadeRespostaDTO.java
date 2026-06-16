package br.com.hqhub.dto;

import java.time.LocalDateTime;

import br.com.hqhub.entity.StatusAmizade;

public record AmizadeRespostaDTO(
        Long id,
        UsuarioRespostaDTO solicitante,
        UsuarioRespostaDTO solicitado,
        StatusAmizade status,
        LocalDateTime dataSolicitacao,
        LocalDateTime dataResposta) {
}
