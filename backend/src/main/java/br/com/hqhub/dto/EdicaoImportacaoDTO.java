package br.com.hqhub.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;

public record EdicaoImportacaoDTO(
        @NotBlank(message = "Número da edição é obrigatório.")
        String numero,

        String tituloChamada,
        LocalDate dataPublicacao,
        String publicadoTexto,
        String editora,
        String licenciador,
        String categoria,
        String genero,
        String status,
        Integer numeroPaginas,
        String formato,
        BigDecimal precoCapa,
        String urlCapa,
        String descricao,

        @Valid
        List<HistoriaImportacaoDTO> historias) {
}
