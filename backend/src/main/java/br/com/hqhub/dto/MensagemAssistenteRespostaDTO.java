package br.com.hqhub.dto;

import java.time.LocalDateTime;

import br.com.hqhub.entity.RemetenteMensagemAssistente;

public record MensagemAssistenteRespostaDTO(
        Long id,
        RemetenteMensagemAssistente remetente,
        String conteudo,
        String origem,
        String dados,
        LocalDateTime dataCriacao) {
}
