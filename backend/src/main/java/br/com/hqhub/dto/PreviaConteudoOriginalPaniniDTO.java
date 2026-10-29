package br.com.hqhub.dto;

import java.util.List;
import java.math.BigDecimal;
import java.time.LocalDate;

public record PreviaConteudoOriginalPaniniDTO(
        String urlPanini,
        String tituloProduto,
        String conteudoOriginalBruto,
        List<ReferenciaConteudoOriginalPaniniDTO> referencias,
        ProdutoPaniniDTO produto) {

    public record ProdutoPaniniDTO(
            String tituloSerieSugerido,
            String numeroSugerido,
            String numeroAlternativo,
            String descricao,
            String urlCapa,
            String sku,
            String isbn,
            BigDecimal preco,
            LocalDate dataDisponibilidade,
            Integer quantidadePaginas,
            String formato,
            String classificacaoEtaria,
            String categoria,
            String marca,
            List<String> autores) {
    }

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
