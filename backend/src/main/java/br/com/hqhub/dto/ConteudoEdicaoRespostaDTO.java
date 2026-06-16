package br.com.hqhub.dto;

import java.time.LocalDateTime;

import br.com.hqhub.entity.TipoConteudoEdicao;

public record ConteudoEdicaoRespostaDTO(
        Long id,
        EdicaoRespostaDTO edicao,
        HistoriaRespostaDTO historia,
        Integer ordem,
        String tituloUsado,
        Integer paginaInicio,
        Integer paginaFim,
        Integer quantidadePaginas,
        TipoConteudoEdicao tipo,
        String observacoes,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
