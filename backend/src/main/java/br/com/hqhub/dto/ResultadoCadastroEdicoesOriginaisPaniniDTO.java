package br.com.hqhub.dto;

import java.util.List;

import br.com.hqhub.dto.PreviaConteudoOriginalPaniniDTO.CandidatoEdicaoOriginalPaniniDTO;

public record ResultadoCadastroEdicoesOriginaisPaniniDTO(
        List<ResultadoEdicaoOriginalPaniniDTO> resultados) {

    public record ResultadoEdicaoOriginalPaniniDTO(
            int indice,
            CandidatoEdicaoOriginalPaniniDTO candidato,
            String erro) {
    }
}
