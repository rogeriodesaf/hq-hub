package br.com.hqhub.mapper;

import br.com.hqhub.dto.AtualizacaoEdicaoDTO;
import br.com.hqhub.dto.CadastroEdicaoDTO;
import br.com.hqhub.dto.EdicaoRespostaDTO;
import br.com.hqhub.dto.EditoraResumoDTO;
import br.com.hqhub.dto.SerieResumoDTO;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.Serie;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class EdicaoMapper {

    public Edicao paraEntidade(CadastroEdicaoDTO dto, Serie serie) {
        Edicao edicao = new Edicao();
        edicao.setNumero(dto.numero());
        edicao.setTitulo(dto.titulo());
        edicao.setDescricao(dto.descricao());
        edicao.setDataPublicacao(dto.dataPublicacao());
        edicao.setUrlCapa(dto.urlCapa());
        edicao.setCodigoBarras(dto.codigoBarras());
        edicao.setQuantidadePaginas(dto.quantidadePaginas());
        edicao.setPrecoCapa(dto.precoCapa());
        edicao.setFonteExterna(dto.fonteExterna());
        edicao.setIdExterno(dto.idExterno());
        edicao.setUrlOrigem(dto.urlOrigem());
        edicao.setSerie(serie);
        return edicao;
    }

    public void atualizarEntidade(Edicao edicao, AtualizacaoEdicaoDTO dto, Serie serie) {
        edicao.setNumero(dto.numero());
        edicao.setTitulo(dto.titulo());
        edicao.setDescricao(dto.descricao());
        edicao.setDataPublicacao(dto.dataPublicacao());
        edicao.setUrlCapa(dto.urlCapa());
        edicao.setCodigoBarras(dto.codigoBarras());
        edicao.setQuantidadePaginas(dto.quantidadePaginas());
        edicao.setPrecoCapa(dto.precoCapa());
        edicao.setFonteExterna(dto.fonteExterna());
        edicao.setIdExterno(dto.idExterno());
        edicao.setUrlOrigem(dto.urlOrigem());
        edicao.setSerie(serie);
    }

    public EdicaoRespostaDTO paraResposta(Edicao edicao) {
        Serie serie = edicao.getSerie();

        return new EdicaoRespostaDTO(
                edicao.getId(),
                edicao.getNumero(),
                edicao.getTitulo(),
                edicao.getDescricao(),
                edicao.getDataPublicacao(),
                edicao.getUrlCapa(),
                edicao.getCodigoBarras(),
                edicao.getQuantidadePaginas(),
                edicao.getPrecoCapa(),
                edicao.getFonteExterna(),
                edicao.getIdExterno(),
                edicao.getUrlOrigem(),
                new SerieResumoDTO(
                        serie.getId(),
                        serie.getTitulo(),
                        new EditoraResumoDTO(serie.getEditora().getId(), serie.getEditora().getNome())),
                edicao.getDataCriacao(),
                edicao.getDataAtualizacao());
    }
}
