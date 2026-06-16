package br.com.hqhub.dto;

import java.time.LocalDateTime;

public record CriadorRespostaDTO(
        Long id,
        String nome,
        String nomeArtistico,
        String fonteExterna,
        String idExterno,
        String urlOrigem,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
