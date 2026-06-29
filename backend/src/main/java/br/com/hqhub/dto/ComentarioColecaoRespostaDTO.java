package br.com.hqhub.dto;

import java.time.LocalDateTime;

public record ComentarioColecaoRespostaDTO(
        Long id,
        UsuarioRespostaDTO usuario,
        String texto,
        LocalDateTime dataCriacao) {
}
