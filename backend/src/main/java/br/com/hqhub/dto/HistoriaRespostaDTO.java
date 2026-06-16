package br.com.hqhub.dto;

import java.time.LocalDateTime;

import br.com.hqhub.entity.TipoConteudoEdicao;

public record HistoriaRespostaDTO(
        Long id,
        String titulo,
        String tituloOriginal,
        String tituloPortugues,
        String tituloExibicao,
        String descricao,
        String descricaoOriginal,
        String descricaoPortugues,
        String descricaoExibicao,
        Integer quantidadePaginas,
        TipoConteudoEdicao tipo,
        String fonteExterna,
        String idExterno,
        String urlOrigem,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
