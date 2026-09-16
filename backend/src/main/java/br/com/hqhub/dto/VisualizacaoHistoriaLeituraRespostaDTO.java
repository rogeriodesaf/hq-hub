package br.com.hqhub.dto;

import java.time.LocalDateTime;

public record VisualizacaoHistoriaLeituraRespostaDTO(
        UsuarioRespostaDTO usuario,
        LocalDateTime dataVisualizacao) {
}
