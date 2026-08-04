package br.com.hqhub.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;

public record AtualizacaoCanalParceiroDTO(
        @NotNull(message = "Informe os dados do canal parceiro.")
        @Valid CanalParceiroDTO partnerChannel) {
}
