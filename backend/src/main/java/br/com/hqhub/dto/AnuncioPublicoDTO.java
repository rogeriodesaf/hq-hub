package br.com.hqhub.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import br.com.hqhub.entity.EstadoConservacao;
import br.com.hqhub.entity.TipoAnuncio;

public record AnuncioPublicoDTO(
        Long id,
        String tituloEdicao,
        String urlCapa,
        String nomeAnunciante,
        TipoAnuncio tipoAnuncio,
        BigDecimal preco,
        EstadoConservacao estadoConservacao,
        String descricao,
        String cidade,
        String estado,
        String linkContatoWhatsapp,
        LocalDateTime dataCriacao) {
}
