package br.com.hqhub.dto;

import java.time.LocalDateTime;

public record UsuarioRespostaDTO(
        Long id,
        String nome,
        String email,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
