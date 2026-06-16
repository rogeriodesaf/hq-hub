package br.com.hqhub.dto;

import jakarta.validation.constraints.Size;

public record CadastroConversaAssistenteDTO(
        @Size(max = 120, message = "O título deve ter no máximo 120 caracteres.")
        String titulo) {
}
