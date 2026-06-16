package br.com.hqhub.dto;

import java.time.LocalDateTime;

public record SerieRespostaDTO(
        Long id,
        String titulo,
        String descricao,
        Integer anoInicio,
        Integer anoFim,
        Integer volume,
        Integer ordemCronologica,
        String fonteExterna,
        String idExterno,
        String urlOrigem,
        EditoraResumoDTO editora,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
