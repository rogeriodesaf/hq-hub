package br.com.hqhub.dto;

import br.com.hqhub.entity.TipoContribuicaoCatalogo;
import br.com.hqhub.entity.TipoPublicacaoRelacionada;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CadastroContribuicaoCatalogoDTO(
        @NotNull(message = "A edição é obrigatória.")
        Long edicaoId,

        @NotNull(message = "O tipo da contribuição é obrigatório.")
        TipoContribuicaoCatalogo tipo,

        @Size(max = 1000, message = "A URL da capa deve ter no máximo 1000 caracteres.")
        String urlCapaSugerida,

        Long edicaoDestinoId,

        TipoPublicacaoRelacionada tipoPublicacaoRelacionada,

        @Size(max = 100, message = "Fonte externa deve ter no máximo 100 caracteres.")
        String fonteExterna,

        @Size(max = 1000, message = "URL da fonte deve ter no máximo 1000 caracteres.")
        String urlFonte,

        String dadosSugeridosJson,

        @Size(max = 1000, message = "Observações devem ter no máximo 1000 caracteres.")
        String observacoes) {
}
