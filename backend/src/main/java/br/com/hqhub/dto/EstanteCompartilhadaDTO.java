package br.com.hqhub.dto;

import java.util.List;

import br.com.hqhub.entity.StatusLeitura;

public record EstanteCompartilhadaDTO(
        Long usuarioId,
        String nome,
        List<Editora> editoras) {

    public record Editora(String nome, List<Serie> series) {
    }

    public record Serie(String titulo, Integer volume, List<Edicao> edicoes) {
    }

    public record Edicao(
            Long id,
            String numero,
            String titulo,
            String urlCapa,
            StatusLeitura statusLeitura) {
    }
}
