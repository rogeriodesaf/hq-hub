package br.com.hqhub.dto;

import java.time.LocalDateTime;

public record FotoAnuncioRespostaDTO(
        Long id,
        String urlImagem,
        Boolean principal,
        LocalDateTime dataCriacao) {
}
