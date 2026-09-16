package br.com.hqhub.dto;

import java.time.LocalDateTime;

public record HistoriaLeituraRespostaDTO(
        Long id,
        UsuarioRespostaDTO usuario,
        String texto,
        String urlImagem,
        String tituloHq,
        boolean visualizada,
        long totalVisualizacoes,
        LocalDateTime dataCriacao,
        LocalDateTime dataExpiracao) {
}
