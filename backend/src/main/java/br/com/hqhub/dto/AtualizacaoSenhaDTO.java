package br.com.hqhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record AtualizacaoSenhaDTO(
        @NotBlank(message = "Senha atual e obrigatoria.")
        String senhaAtual,

        @NotBlank(message = "Nova senha e obrigatoria.")
        @Size(min = 6, message = "Nova senha deve ter no minimo 6 caracteres.")
        String novaSenha) {
}
