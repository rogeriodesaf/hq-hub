package br.com.hqhub.dto;

import java.util.List;

public record PublicacoesBrasileirasEdicaoOriginalDTO(
        EdicaoOriginalPublicacoesBrasilDTO edicaoEstrangeira,
        int totalPublicacoes,
        int totalHistoriasOriginais,
        List<PublicacaoBrasileiraResumoDTO> publicacoes) {
}
