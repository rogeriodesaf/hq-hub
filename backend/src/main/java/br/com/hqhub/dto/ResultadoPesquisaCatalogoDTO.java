package br.com.hqhub.dto;

import java.time.LocalDate;

public record ResultadoPesquisaCatalogoDTO(
        Long id,
        String idExterno,
        FonteResultadoCatalogo fonte,
        String titulo,
        String numero,
        String nomeVolume,
        Integer serieVolume,
        String urlCapa,
        LocalDate dataPublicacao,
        Boolean jaCadastrada,
        String urlOrigem) {
}
