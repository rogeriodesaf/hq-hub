package br.com.hqhub.mapper;

import br.com.hqhub.dto.AtualizacaoLinkEdicaoDTO;
import br.com.hqhub.dto.CadastroLinkEdicaoDTO;
import br.com.hqhub.dto.LinkEdicaoRespostaDTO;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.LinkEdicao;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class LinkEdicaoMapper {

    public LinkEdicao paraEntidade(CadastroLinkEdicaoDTO dto, Edicao edicao) {
        LinkEdicao link = new LinkEdicao();
        link.setEdicao(edicao);
        link.setTipo(dto.tipo());
        link.setTitulo(dto.titulo());
        link.setUrl(dto.url());
        link.setObservacoes(dto.observacoes());
        return link;
    }

    public void atualizarEntidade(LinkEdicao link, AtualizacaoLinkEdicaoDTO dto) {
        link.setTipo(dto.tipo());
        link.setTitulo(dto.titulo());
        link.setUrl(dto.url());
        link.setObservacoes(dto.observacoes());
    }

    public LinkEdicaoRespostaDTO paraResposta(LinkEdicao link) {
        return new LinkEdicaoRespostaDTO(
                link.getId(),
                link.getEdicao().getId(),
                link.getTipo(),
                link.getTitulo(),
                link.getUrl(),
                link.getObservacoes(),
                link.getDataCriacao(),
                link.getDataAtualizacao());
    }
}
