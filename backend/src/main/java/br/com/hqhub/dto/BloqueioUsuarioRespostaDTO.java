package br.com.hqhub.dto;

import java.time.LocalDateTime;

public record BloqueioUsuarioRespostaDTO(
        Long id,
        UsuarioRespostaDTO usuarioBloqueado,
        String motivo,
        LocalDateTime dataBloqueio) {
}
