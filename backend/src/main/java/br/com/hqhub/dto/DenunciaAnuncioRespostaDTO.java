package br.com.hqhub.dto;

import java.time.LocalDateTime;

import br.com.hqhub.entity.StatusDenuncia;

public record DenunciaAnuncioRespostaDTO(
        Long id,
        AnuncioRespostaDTO anuncio,
        String motivo,
        String descricao,
        StatusDenuncia status,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
