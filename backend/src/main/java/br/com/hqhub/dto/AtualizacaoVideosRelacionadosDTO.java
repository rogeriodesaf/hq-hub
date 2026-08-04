package br.com.hqhub.dto;

import java.util.List;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record AtualizacaoVideosRelacionadosDTO(
        @NotNull(message = "Informe a lista de vídeos relacionados.")
        @Size(max = 3, message = "A postagem pode ter no máximo 3 vídeos relacionados.")
        List<@Valid CadastroVideoRelacionadoDTO> relatedVideos) {
}
