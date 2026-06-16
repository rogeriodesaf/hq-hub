package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CadastroCriadorDTO(
        @NotBlank(message = "Nome do criador é obrigatório.")
        @Size(max = 255, message = "Nome do criador deve ter no máximo 255 caracteres.")
        String nome,

        @Size(max = 255, message = "Nome artístico deve ter no máximo 255 caracteres.")
        String nomeArtistico,

        @Size(max = 100, message = "Fonte externa deve ter no máximo 100 caracteres.")
        String fonteExterna,

        @Size(max = 255, message = "Id externo deve ter no máximo 255 caracteres.")
        String idExterno,

        @Size(max = 1000, message = "URL de origem deve ter no máximo 1000 caracteres.")
        String urlOrigem) {
}
