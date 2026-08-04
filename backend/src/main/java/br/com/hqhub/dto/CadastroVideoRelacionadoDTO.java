package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;

public record CadastroVideoRelacionadoDTO(
        @NotBlank(message = "Título do vídeo é obrigatório.")
        @Size(max = 200, message = "Título do vídeo deve ter no máximo 200 caracteres.")
        String title,

        @NotBlank(message = "URL do vídeo é obrigatória.")
        @Size(max = 1000, message = "URL do vídeo deve ter no máximo 1000 caracteres.")
        String url,

        @Size(max = 1000, message = "Thumbnail deve ter no máximo 1000 caracteres.")
        String thumbnail,

        @Size(max = 200, message = "Nome do canal deve ter no máximo 200 caracteres.")
        String channelName,

        @Positive(message = "Duração deve ser maior que zero.")
        Integer durationSeconds,

        @PositiveOrZero(message = "Visualizações não podem ser negativas.")
        Long viewCount) {
}
