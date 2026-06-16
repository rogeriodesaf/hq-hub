package br.com.hqhub.dto;

import java.util.List;

public record CruzamentoEdicaoRespostaDTO(
        EdicaoRespostaDTO edicaoOriginal,
        EdicaoRespostaDTO edicaoComparada,
        List<ConteudoEdicaoRespostaDTO> conteudosOriginais,
        List<PublicacaoHistoriaRespostaDTO> historiasIncluidas,
        List<ConteudoEdicaoRespostaDTO> conteudosFora,
        long totalConteudosOriginais,
        long totalHistoriasIncluidas,
        long totalConteudosFora) {
}
