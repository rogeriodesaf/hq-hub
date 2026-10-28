package br.com.hqhub.dto;

import java.util.List;

public record PreviaConteudoOriginalPaniniDTO(
        String urlPanini,
        String tituloProduto,
        String conteudoOriginalBruto,
        List<ReferenciaConteudoOriginalPaniniDTO> referencias) {

    public record ReferenciaConteudoOriginalPaniniDTO(
            int indice,
            String textoOriginal,
            String serie,
            Integer anoSerie,
            String numero,
            String complemento,
            String statusResolucao,
            List<CandidatoEdicaoOriginalPaniniDTO> candidatos) {
    }

    public record CandidatoEdicaoOriginalPaniniDTO(
            Long id,
            String serie,
            String numero,
            Integer anoInicio,
            String editora,
            String urlCapa) {
    }
}
