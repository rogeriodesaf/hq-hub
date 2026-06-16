package br.com.hqhub.dto;

import java.util.List;

public record PaginaRespostaDTO<T>(
        List<T> itens,
        int pagina,
        int tamanho,
        long totalItens,
        int totalPaginas) {
}
