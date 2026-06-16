package br.com.hqhub.mapper;

import br.com.hqhub.dto.CadastroConteudoEdicaoDTO;
import br.com.hqhub.dto.ConteudoEdicaoRespostaDTO;
import br.com.hqhub.entity.ConteudoEdicao;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.Historia;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ConteudoEdicaoMapper {

    private final EdicaoMapper edicaoMapper;
    private final HistoriaMapper historiaMapper;

    public ConteudoEdicaoMapper(EdicaoMapper edicaoMapper, HistoriaMapper historiaMapper) {
        this.edicaoMapper = edicaoMapper;
        this.historiaMapper = historiaMapper;
    }

    public ConteudoEdicao paraEntidade(CadastroConteudoEdicaoDTO dto, Edicao edicao, Historia historia) {
        ConteudoEdicao conteudo = new ConteudoEdicao();
        conteudo.setEdicao(edicao);
        conteudo.setHistoria(historia);
        conteudo.setOrdem(dto.ordem());
        conteudo.setTituloUsado(dto.tituloUsado());
        conteudo.setPaginaInicio(dto.paginaInicio());
        conteudo.setPaginaFim(dto.paginaFim());
        conteudo.setQuantidadePaginas(dto.quantidadePaginas());
        conteudo.setTipo(dto.tipo());
        conteudo.setObservacoes(dto.observacoes());
        return conteudo;
    }

    public ConteudoEdicaoRespostaDTO paraResposta(ConteudoEdicao conteudo) {
        return new ConteudoEdicaoRespostaDTO(
                conteudo.getId(),
                edicaoMapper.paraResposta(conteudo.getEdicao()),
                historiaMapper.paraResposta(conteudo.getHistoria()),
                conteudo.getOrdem(),
                conteudo.getTituloUsado(),
                conteudo.getPaginaInicio(),
                conteudo.getPaginaFim(),
                conteudo.getQuantidadePaginas(),
                conteudo.getTipo(),
                conteudo.getObservacoes(),
                conteudo.getDataCriacao(),
                conteudo.getDataAtualizacao());
    }
}
