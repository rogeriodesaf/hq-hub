package br.com.hqhub.dto;

import jakarta.validation.constraints.NotNull;

public record AtualizacaoProgressoLeituraDTO(@NotNull Boolean lido) {
}
