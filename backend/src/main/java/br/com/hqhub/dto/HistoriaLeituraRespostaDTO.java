package br.com.hqhub.dto;

import java.time.LocalDateTime;
import java.util.List;

public record HistoriaLeituraRespostaDTO(
        Long id,
        UsuarioRespostaDTO usuario,
        String texto,
        String urlImagem,
        String tituloHq,
        boolean visualizada,
        long totalVisualizacoes,
        long totalCurtidas,
        boolean curtidaPeloUsuario,
        List<ComentarioHistoriaLeituraDTO> comentarios,
        LocalDateTime dataCriacao,
        LocalDateTime dataExpiracao) {
}
