package br.com.hqhub.dto;

import br.com.hqhub.entity.VisibilidadeColecao;
import jakarta.validation.constraints.NotNull;

public record AtualizacaoConfiguracaoColecaoDTO(
        @NotNull(message = "A visibilidade da coleção é obrigatória.")
        VisibilidadeColecao visibilidadeColecao,

        @NotNull(message = "Informe se o valor da coleção deve ser exibido.")
        Boolean exibirValorColecao) {
}
