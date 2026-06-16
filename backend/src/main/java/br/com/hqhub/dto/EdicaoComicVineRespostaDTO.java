package br.com.hqhub.dto;

import java.util.List;

public record EdicaoComicVineRespostaDTO(
        String idExterno,
        String numero,
        String titulo,
        String nomeVolume,
        String idVolume,
        String dataCapa,
        String dataVenda,
        String descricao,
        String descricaoOriginal,
        String descricaoPortugues,
        String descricaoExibicao,
        String urlOrigem,
        String urlImagem,
        List<CreditoComicVineRespostaDTO> creditos,
        List<String> personagens,
        List<String> conteudos) {
}
