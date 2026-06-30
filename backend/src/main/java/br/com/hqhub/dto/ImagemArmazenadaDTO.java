package br.com.hqhub.dto;

public record ImagemArmazenadaDTO(
        String urlImagem,
        String publicIdCloudinary,
        String tipoMime,
        long tamanhoBytes,
        Integer largura,
        Integer altura) {
}
