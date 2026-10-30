package br.com.hqhub.dto;

import java.util.List;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CadastroEdicoesOriginaisPaniniDTO(
        @NotBlank @Size(max = 1000) String urlPanini,
        @NotEmpty @Size(max = 100) List<@Valid ReferenciaEdicaoOriginalPaniniDTO> referencias) {

    public record ReferenciaEdicaoOriginalPaniniDTO(
            @NotNull Integer indice,
            @NotBlank @Size(max = 255) String serie,
            Integer anoSerie,
            @NotBlank @Size(max = 50) String numero,
            Long edicaoExistenteId) {
    }
}
