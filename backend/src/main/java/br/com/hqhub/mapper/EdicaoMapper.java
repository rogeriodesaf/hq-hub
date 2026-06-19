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
        edicao.setDescricaoOriginal(dto.descricao());
        edicao.setDataPublicacao(dto.dataPublicacao());
        edicao.setUrlCapa(dto.urlCapa());
        edicao.setCodigoBarras(dto.codigoBarras());
        edicao.setQuantidadePaginas(dto.quantidadePaginas());
        edicao.setPrecoCapa(dto.precoCapa());
        edicao.setFormato(dto.formato());
        edicao.setFonteExterna(dto.fonteExterna());
        edicao.setIdExterno(dto.idExterno());
        edicao.setUrlOrigem(dto.urlOrigem());
        if ("COMICVINE".equals(dto.fonteExterna())) {
            edicao.setIdComicVine(dto.idExterno());
            edicao.setUrlComicVine(dto.urlOrigem());
        }
        edicao.setSerie(serie);
        return edicao;
    }

    public void atualizarEntidade(Edicao edicao, AtualizacaoEdicaoDTO dto, Serie serie) {
        edicao.setNumero(dto.numero());
        edicao.setTitulo(dto.titulo());
        edicao.setDescricao(dto.descricao());
        edicao.setDescricaoOriginal(dto.descricao());
        edicao.setDataPublicacao(dto.dataPublicacao());
        edicao.setUrlCapa(dto.urlCapa());
        edicao.setCodigoBarras(dto.codigoBarras());
        edicao.setQuantidadePaginas(dto.quantidadePaginas());
        edicao.setPrecoCapa(dto.precoCapa());
        edicao.setFormato(dto.formato());
        edicao.setFonteExterna(dto.fonteExterna());
        edicao.setIdExterno(dto.idExterno());
        edicao.setUrlOrigem(dto.urlOrigem());
        if ("COMICVINE".equals(dto.fonteExterna())) {
            edicao.setIdComicVine(dto.idExterno());
            edicao.setUrlComicVine(dto.urlOrigem());
        }
        edicao.setSerie(serie);
    }

    public EdicaoRespostaDTO paraResposta(Edicao edicao) {
        Serie serie = edicao.getSerie();

        return new EdicaoRespostaDTO(
                edicao.getId(),
                edicao.getNumero(),
                edicao.getTitulo(),
                edicao.getDescricao(),
                edicao.getDescricaoOriginal(),
                edicao.getDescricaoPortugues(),
                descricaoExibicao(edicao),
                edicao.getNomeVolume(),
                edicao.getDataCobertura(),
                edicao.getDataDisponibilidadeLoja(),
                edicao.getDataPublicacao(),
                edicao.getUrlCapa(),
                edicao.getCodigoBarras(),
                edicao.getQuantidadePaginas(),
                edicao.getPrecoCapa(),
                edicao.getFormato(),
                edicao.getFonteExterna(),
                edicao.getIdExterno(),
                edicao.getUrlOrigem(),
                edicao.getUrlComicVine(),
                edicao.getIdComicVine(),
                new SerieResumoDTO(
                        serie.getId(),
                        serie.getTitulo(),
                        new EditoraResumoDTO(serie.getEditora().getId(), serie.getEditora().getNome())),
                edicao.getDataCriacao(),
                edicao.getDataAtualizacao());
    }

    private String descricaoExibicao(Edicao edicao) {
        if (edicao.getDescricaoPortugues() != null && !edicao.getDescricaoPortugues().isBlank()) {
            return edicao.getDescricaoPortugues();
        }

        if (edicao.getDescricaoOriginal() != null && !edicao.getDescricaoOriginal().isBlank()) {
            return edicao.getDescricaoOriginal();
        }

        if (edicao.getDescricao() != null && !edicao.getDescricao().isBlank()) {
            return edicao.getDescricao();
        }

        return "Descrição não disponível.";
    }
}
