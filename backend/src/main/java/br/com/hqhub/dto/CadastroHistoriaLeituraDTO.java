package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CadastroHistoriaLeituraDTO(
        @Size(max = 280) String texto,
        @NotBlank @Size(max = 1000) String urlImagem,
        @Size(max = 300) String tituloHq) {
}
