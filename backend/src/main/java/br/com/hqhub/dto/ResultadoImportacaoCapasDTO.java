package br.com.hqhub.dto;

import java.util.List;

public record ResultadoImportacaoCapasDTO(
        int total,
        int sucessos,
        int erros,
        List<ItemImportacaoCapaDTO> itens) {

    public record ItemImportacaoCapaDTO(
            Long idEdicao,
            String urlImagem,
            boolean sucesso,
            String mensagem,
            CapaEdicaoRespostaDTO capa) {
    }
}
