package br.com.hqhub.dto;

import java.util.List;

public record OrigemImportacaoCatalogoDTO(
        String arquivoEntrada,
        String url,
        List<String> urlsProcessadas,
        String geradoEm,
        String gerador) {
}
