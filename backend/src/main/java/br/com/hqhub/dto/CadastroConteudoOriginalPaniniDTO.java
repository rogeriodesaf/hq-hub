package br.com.hqhub.dto;

import java.util.List;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

public record CadastroConteudoOriginalPaniniDTO(
        @NotNull @Positive Long edicaoBrasileiraId,
        @NotBlank @Size(max = 1000) String urlPanini,
        @NotEmpty List<@Valid VinculoConteudoOriginalPaniniDTO> vinculos) {

    public record VinculoConteudoOriginalPaniniDTO(
            @NotNull @Positive Long edicaoOriginalId,
            @NotNull @Size(max = 500) String referenciaOriginal) {
    }
}
