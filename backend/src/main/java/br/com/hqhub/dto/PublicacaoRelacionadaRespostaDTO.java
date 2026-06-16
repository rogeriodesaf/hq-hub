package br.com.hqhub.dto;

import java.time.LocalDateTime;

import br.com.hqhub.entity.TipoPublicacaoRelacionada;

public record PublicacaoRelacionadaRespostaDTO(
        Long id,
        EdicaoRespostaDTO edicaoOrigem,
        EdicaoRespostaDTO edicaoDestino,
        TipoPublicacaoRelacionada tipo,
        String fonteExterna,
        String urlOrigem,
        String observacoes,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
