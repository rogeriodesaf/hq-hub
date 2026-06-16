package br.com.hqhub.dto;

public record ContatoAnuncioRespostaDTO(
        Long anuncioId,
        String contatoWhatsapp,
        String mensagem,
        String linkWhatsapp,
        String avisoResponsabilidade) {
}
