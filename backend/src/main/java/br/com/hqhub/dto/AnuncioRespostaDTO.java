package br.com.hqhub.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import br.com.hqhub.entity.EstadoConservacao;
import br.com.hqhub.entity.StatusAnuncio;
import br.com.hqhub.entity.TipoAnuncio;

public record AnuncioRespostaDTO(
        Long id,
        UsuarioRespostaDTO anunciante,
        ItemColecaoRespostaDTO itemColecao,
        TipoAnuncio tipoAnuncio,
        BigDecimal preco,
        EstadoConservacao estadoConservacao,
        String descricao,
        String cidade,
        String estado,
        Boolean exibirWhatsapp,
        StatusAnuncio status,
        String avisoResponsabilidade,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
