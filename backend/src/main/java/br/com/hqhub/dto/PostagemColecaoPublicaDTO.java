package br.com.hqhub.dto;

import java.util.List;

import br.com.hqhub.entity.StatusLeitura;

public record PostagemColecaoPublicaDTO(
        Long postagemId,
        Long usuarioId,
        String nomeUsuario,
        String conteudo,
        String titulo,
        String editora,
        List<Edicao> edicoes) {

    public record Edicao(
            Long id,
            String numero,
            String titulo,
            String urlCapa,
            StatusLeitura statusLeitura) {
    }
}
