package br.com.hqhub.dto;

import java.math.BigDecimal;

import br.com.hqhub.entity.EstadoConservacao;
import br.com.hqhub.entity.TipoAnuncio;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CadastroAnuncioDTO(
        @NotNull(message = "Item da coleção é obrigatório.")
        Long itemColecaoId,

        @NotNull(message = "Tipo de anúncio obrigatório.")
        TipoAnuncio tipoAnuncio,

        @DecimalMin(value = "0.00", message = "O preço não pode ser negativo.")
        BigDecimal preco,

        @NotNull(message = "Estado de conservação obrigatório.")
        EstadoConservacao estadoConservacao,

        @Size(max = 1000, message = "A descrição deve ter no máximo 1000 caracteres.")
        String descricao,

        String cidade,

        @Size(min = 2, max = 2, message = "O estado deve ter a sigla com 2 caracteres.")
        String estado,

        String contatoWhatsapp,

        Boolean exibirWhatsapp) {
}
