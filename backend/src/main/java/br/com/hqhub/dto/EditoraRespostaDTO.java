package br.com.hqhub.dto;

import java.time.LocalDateTime;

public record EditoraRespostaDTO(
        Long id,
        String nome,
        String descricao,
        String paisOrigem,
        String fonteExterna,
        String idExterno,
        String urlOrigem,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
