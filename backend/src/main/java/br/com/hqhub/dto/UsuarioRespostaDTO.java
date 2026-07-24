package br.com.hqhub.dto;

import java.time.LocalDateTime;

public record UsuarioRespostaDTO(
        Long id,
        String nome,
        String email,
        String perfil,
        String bio,
        String fotoPerfilUrl,
        String fotoPerfilThumbnailUrl,
        String capaPerfilUrl,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
