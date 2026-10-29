package br.com.hqhub.dto;

import java.util.List;

public record ResultadoCadastroEdicaoBrasileiraPaniniDTO(
        EdicaoRespostaDTO edicao,
        boolean criada,
        boolean capaArmazenada,
        List<String> avisos) {
}
