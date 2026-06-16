package br.com.hqhub.dto;

import java.math.BigDecimal;

import br.com.hqhub.entity.EstadoConservacao;
import br.com.hqhub.entity.TipoAnuncio;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CadastroAnuncioDTO(
        @NotNull(message = "O item da coleção é obrigatório.")
        Long itemColecaoId,

        @NotNull(message = "O tipo do anúncio é obrigatório.")
        TipoAnuncio tipoAnuncio,

        @DecimalMin(value = "0.00", message = "O preço não pode ser negativo.")
        BigDecimal preco,

        @NotNull(message = "O estado de conservação é obrigatório.")
        EstadoConservacao estadoConservacao,

        @Size(max = 1000, message = "A descrição deve ter no máximo 1000 caracteres.")
        String descricao,

        @NotBlank(message = "A cidade é obrigatória.")
        String cidade,

        @NotBlank(message = "O estado é obrigatório.")
        @Size(min = 2, max = 2, message = "O estado deve ter a sigla com 2 caracteres.")
        String estado,

        String contatoWhatsapp,

        Boolean exibirWhatsapp) {
}
