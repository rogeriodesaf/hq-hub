package br.com.hqhub.dto;

import java.time.LocalDateTime;

import br.com.hqhub.entity.StatusValidacao;
import br.com.hqhub.entity.StatusPublicacaoHistoria;
import br.com.hqhub.entity.TipoPublicacaoHistoria;

public record PublicacaoHistoriaRespostaDTO(
        Long id,
        HistoriaRespostaDTO historia,
        EdicaoRespostaDTO edicaoOriginal,
        EdicaoRespostaDTO edicaoPublicada,
        StatusPublicacaoHistoria status,
        TipoPublicacaoHistoria tipoPublicacaoHistoria,
        String fonteInformacao,
        String urlFonteInformacao,
        StatusValidacao statusValidacao,
        String tituloUsado,
        Integer paginasPublicadas,
        Integer paginasCortadas,
        String fonteExterna,
        String urlOrigem,
        String observacoes,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
