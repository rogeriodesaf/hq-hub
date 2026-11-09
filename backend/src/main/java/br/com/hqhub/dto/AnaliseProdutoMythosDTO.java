package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record AnaliseProdutoMythosDTO(@NotBlank @Size(max = 1000) String urlMythos) {}
