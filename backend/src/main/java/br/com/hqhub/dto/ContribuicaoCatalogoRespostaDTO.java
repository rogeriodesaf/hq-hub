package br.com.hqhub.dto;

import java.time.LocalDateTime;

import br.com.hqhub.entity.StatusContribuicaoCatalogo;
import br.com.hqhub.entity.TipoContribuicaoCatalogo;
import br.com.hqhub.entity.TipoPublicacaoRelacionada;

public record ContribuicaoCatalogoRespostaDTO(
        Long id,
        UsuarioRespostaDTO usuario,
        EdicaoRespostaDTO edicao,
        TipoContribuicaoCatalogo tipo,
        StatusContribuicaoCatalogo status,
        String urlCapaSugerida,
        Long edicaoDestinoId,
        TipoPublicacaoRelacionada tipoPublicacaoRelacionada,
        String fonteExterna,
        String urlFonte,
        String dadosSugeridosJson,
        String observacoes,
        String mensagemRevisao,
        UsuarioRespostaDTO revisor,
        LocalDateTime dataRevisao,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
