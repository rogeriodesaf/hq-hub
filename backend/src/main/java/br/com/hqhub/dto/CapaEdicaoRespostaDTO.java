package br.com.hqhub.dto;

import java.time.LocalDateTime;

import br.com.hqhub.entity.OrigemCapaEdicao;
import br.com.hqhub.entity.StatusCapaEdicao;

public record CapaEdicaoRespostaDTO(
        Long id,
        Long edicaoId,
        String urlImagem,
        String publicIdCloudinary,
        Long enviadoPorUsuarioId,
        String enviadoPorNome,
        StatusCapaEdicao status,
        OrigemCapaEdicao origem,
        String observacao,
        LocalDateTime dataEnvio,
        LocalDateTime dataAprovacao,
        Long aprovadoPorUsuarioId,
        String aprovadoPorNome) {
}
