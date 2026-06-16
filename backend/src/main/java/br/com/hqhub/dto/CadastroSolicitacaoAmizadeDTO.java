package br.com.hqhub.dto;

import jakarta.validation.constraints.NotNull;

public record CadastroSolicitacaoAmizadeDTO(
        @NotNull(message = "O usuário solicitado é obrigatório.")
        Long usuarioSolicitadoId) {
}
