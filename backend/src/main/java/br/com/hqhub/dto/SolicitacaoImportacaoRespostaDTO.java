package br.com.hqhub.dto;

import java.time.LocalDateTime;

import br.com.hqhub.entity.StatusSolicitacaoImportacao;

public record SolicitacaoImportacaoRespostaDTO(
        Long id,
        String fonteExterna,
        String termo,
        String urlOrigem,
        StatusSolicitacaoImportacao status,
        String mensagem,
        String resultadoJson,
        LocalDateTime dataProcessamento,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
