package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record ImagemFeedDTO(
        @NotBlank
        @Size(max = 1000)
        String urlImagem,

        @NotBlank
        @Size(max = 1000)
        String urlThumbnail,

        @NotBlank
        @Size(max = 255)
        String nomeArquivo,

        @NotBlank
        @Size(max = 80)
        String tipoMime,

        @NotNull
        Long tamanhoBytes,

        Integer largura,

        Integer altura,

        Integer ordem) {
}
