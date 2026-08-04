package br.com.hqhub.dto;

import java.util.UUID;

public record VideoRelacionadoDTO(
        UUID id,
        String title,
        String url,
        String thumbnail,
        String channelName,
        Integer durationSeconds,
        Long viewCount) {
}
