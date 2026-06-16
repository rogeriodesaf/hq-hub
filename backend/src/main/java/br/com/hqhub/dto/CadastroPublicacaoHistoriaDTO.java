package br.com.hqhub.dto;

import br.com.hqhub.entity.StatusPublicacaoHistoria;
import br.com.hqhub.entity.TipoPublicacaoHistoria;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CadastroPublicacaoHistoriaDTO(
        @NotNull(message = "História é obrigatória.")
        Long historiaId,

        @NotNull(message = "Edição original é obrigatória.")
        Long edicaoOriginalId,

        @NotNull(message = "Edição publicada é obrigatória.")
        Long edicaoPublicadaId,

        @NotNull(message = "Status da publicação é obrigatório.")
        StatusPublicacaoHistoria status,

        TipoPublicacaoHistoria tipoPublicacaoHistoria,

        @Size(max = 255, message = "Fonte de informação deve ter no máximo 255 caracteres.")
        String fonteInformacao,

        @Size(max = 1000, message = "URL da fonte de informação deve ter no máximo 1000 caracteres.")
        String urlFonteInformacao,

        String tituloUsado,

        Integer paginasPublicadas,

        Integer paginasCortadas,

        @Size(max = 100, message = "Fonte externa deve ter no máximo 100 caracteres.")
        String fonteExterna,

        @Size(max = 1000, message = "URL de origem deve ter no máximo 1000 caracteres.")
        String urlOrigem,

        @Size(max = 1000, message = "Observações devem ter no máximo 1000 caracteres.")
        String observacoes) {
}
