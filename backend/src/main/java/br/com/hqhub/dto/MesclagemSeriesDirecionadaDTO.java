package br.com.hqhub.dto;

import java.util.List;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

public record MesclagemSeriesDirecionadaDTO(
        @NotNull Long serieMantidaId,
        @NotEmpty List<@NotNull Long> seriesDescartadasIds) {
}
