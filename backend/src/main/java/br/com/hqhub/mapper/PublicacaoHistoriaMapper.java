package br.com.hqhub.mapper;

import br.com.hqhub.dto.CadastroPublicacaoHistoriaDTO;
import br.com.hqhub.dto.PublicacaoHistoriaRespostaDTO;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.Historia;
import br.com.hqhub.entity.PublicacaoHistoria;
import br.com.hqhub.entity.TipoPublicacaoHistoria;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class PublicacaoHistoriaMapper {

    private final EdicaoMapper edicaoMapper;
    private final HistoriaMapper historiaMapper;

    public PublicacaoHistoriaMapper(EdicaoMapper edicaoMapper, HistoriaMapper historiaMapper) {
        this.edicaoMapper = edicaoMapper;
        this.historiaMapper = historiaMapper;
    }

    public PublicacaoHistoria paraEntidade(
            CadastroPublicacaoHistoriaDTO dto,
            Historia historia,
            Edicao edicaoOriginal,
            Edicao edicaoPublicada) {
        PublicacaoHistoria publicacao = new PublicacaoHistoria();
        publicacao.setHistoria(historia);
        publicacao.setEdicaoOriginal(edicaoOriginal);
        publicacao.setEdicaoPublicada(edicaoPublicada);
        publicacao.setStatus(dto.status());
        publicacao.setTipoPublicacaoHistoria(dto.tipoPublicacaoHistoria() == null
                ? TipoPublicacaoHistoria.REPUBLICACAO
                : dto.tipoPublicacaoHistoria());
        publicacao.setFonteInformacao(dto.fonteInformacao() == null ? dto.fonteExterna() : dto.fonteInformacao());
        publicacao.setUrlFonteInformacao(dto.urlFonteInformacao() == null ? dto.urlOrigem() : dto.urlFonteInformacao());
        publicacao.setTituloUsado(dto.tituloUsado());
        publicacao.setPaginasPublicadas(dto.paginasPublicadas());
        publicacao.setPaginasCortadas(dto.paginasCortadas());
        publicacao.setFonteExterna(dto.fonteExterna());
        publicacao.setUrlOrigem(dto.urlOrigem());
        publicacao.setObservacoes(dto.observacoes());
        return publicacao;
    }

    public PublicacaoHistoriaRespostaDTO paraResposta(PublicacaoHistoria publicacao) {
        return new PublicacaoHistoriaRespostaDTO(
                publicacao.getId(),
                historiaMapper.paraResposta(publicacao.getHistoria()),
                edicaoMapper.paraResposta(publicacao.getEdicaoOriginal()),
                edicaoMapper.paraResposta(publicacao.getEdicaoPublicada()),
                publicacao.getStatus(),
                publicacao.getTipoPublicacaoHistoria(),
                publicacao.getFonteInformacao(),
                publicacao.getUrlFonteInformacao(),
                publicacao.getStatusValidacao(),
                publicacao.getTituloUsado(),
                publicacao.getPaginasPublicadas(),
                publicacao.getPaginasCortadas(),
                publicacao.getFonteExterna(),
                publicacao.getUrlOrigem(),
                publicacao.getObservacoes(),
                publicacao.getDataCriacao(),
                publicacao.getDataAtualizacao());
    }
}
