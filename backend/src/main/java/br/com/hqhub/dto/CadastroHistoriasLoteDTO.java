package br.com.hqhub.dto;

import java.util.List;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;

public record CadastroHistoriasLoteDTO(
        @NotEmpty(message = "Informe pelo menos uma história.")
        @Size(max = 100, message = "É possível cadastrar no máximo 100 histórias por vez.")
        List<@Valid ItemHistoriaLoteDTO> historias,

        @Size(max = 1000, message = "URL da fonte deve ter no máximo 1000 caracteres.")
        String urlFonte) {
}
