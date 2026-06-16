package br.com.hqhub.dto;

import java.time.LocalDateTime;

import br.com.hqhub.entity.StatusPublicacaoHistoria;

public record PublicacaoHistoriaRespostaDTO(
        Long id,
        HistoriaRespostaDTO historia,
        EdicaoRespostaDTO edicaoOriginal,
        EdicaoRespostaDTO edicaoPublicada,
        StatusPublicacaoHistoria status,
        String tituloUsado,
        Integer paginasPublicadas,
        Integer paginasCortadas,
        String fonteExterna,
        String urlOrigem,
        String observacoes,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
