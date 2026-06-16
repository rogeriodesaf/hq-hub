package br.com.hqhub.mapper;

import br.com.hqhub.dto.CadastroPublicacaoRelacionadaDTO;
import br.com.hqhub.dto.PublicacaoRelacionadaRespostaDTO;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.PublicacaoRelacionada;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class PublicacaoRelacionadaMapper {

    private final EdicaoMapper edicaoMapper;

    public PublicacaoRelacionadaMapper(EdicaoMapper edicaoMapper) {
        this.edicaoMapper = edicaoMapper;
    }

    public PublicacaoRelacionada paraEntidade(CadastroPublicacaoRelacionadaDTO dto, Edicao origem, Edicao destino) {
        PublicacaoRelacionada publicacao = new PublicacaoRelacionada();
        publicacao.setEdicaoOrigem(origem);
        publicacao.setEdicaoDestino(destino);
        publicacao.setTipo(dto.tipo());
        publicacao.setFonteExterna(dto.fonteExterna());
        publicacao.setUrlOrigem(dto.urlOrigem());
        publicacao.setObservacoes(dto.observacoes());
        return publicacao;
    }

    public PublicacaoRelacionadaRespostaDTO paraResposta(PublicacaoRelacionada publicacao) {
        return new PublicacaoRelacionadaRespostaDTO(
                publicacao.getId(),
                edicaoMapper.paraResposta(publicacao.getEdicaoOrigem()),
                edicaoMapper.paraResposta(publicacao.getEdicaoDestino()),
                publicacao.getTipo(),
                publicacao.getFonteExterna(),
                publicacao.getUrlOrigem(),
                publicacao.getObservacoes(),
                publicacao.getDataCriacao(),
                publicacao.getDataAtualizacao());
    }
}
