package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
public record CadastroComentarioHistoriaDTO(@NotBlank @Size(max = 500) String texto) {}
