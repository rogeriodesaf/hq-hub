package br.com.hqhub.dto;

import jakarta.validation.constraints.Size;

public record RevisaoContribuicaoCatalogoDTO(
        @Size(max = 1000, message = "A mensagem de revisão deve ter no máximo 1000 caracteres.")
        String mensagemRevisao) {
}
