package br.com.hqhub.mapper;

import br.com.hqhub.dto.AtualizacaoHistoriaDTO;
import br.com.hqhub.dto.CadastroHistoriaDTO;
import br.com.hqhub.dto.HistoriaRespostaDTO;
import br.com.hqhub.entity.Historia;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class HistoriaMapper {

    public Historia paraEntidade(CadastroHistoriaDTO dto) {
        Historia historia = new Historia();
        historia.setTitulo(dto.titulo());
        historia.setTituloOriginal(dto.tituloOriginal());
        historia.setDescricao(dto.descricao());
        historia.setDescricaoOriginal(dto.descricao());
        historia.setQuantidadePaginas(dto.quantidadePaginas());
        historia.setTipo(dto.tipo());
        historia.setFonteExterna(dto.fonteExterna());
        historia.setIdExterno(dto.idExterno());
        historia.setUrlOrigem(dto.urlOrigem());
        return historia;
    }

    public void atualizarEntidade(Historia historia, AtualizacaoHistoriaDTO dto) {
        historia.setTitulo(dto.titulo());
        historia.setTituloOriginal(dto.tituloOriginal());
        historia.setDescricao(dto.descricao());
        historia.setDescricaoOriginal(dto.descricao());
        historia.setQuantidadePaginas(dto.quantidadePaginas());
        historia.setTipo(dto.tipo());
        historia.setFonteExterna(dto.fonteExterna());
        historia.setIdExterno(dto.idExterno());
        historia.setUrlOrigem(dto.urlOrigem());
    }

    public HistoriaRespostaDTO paraResposta(Historia historia) {
        return new HistoriaRespostaDTO(
                historia.getId(),
                historia.getTitulo(),
                historia.getTituloOriginal(),
                historia.getTituloPortugues(),
                tituloExibicao(historia),
                historia.getDescricao(),
                historia.getDescricaoOriginal(),
                historia.getDescricaoPortugues(),
                descricaoExibicao(historia),
                historia.getQuantidadePaginas(),
                historia.getTipo(),
                historia.getFonteExterna(),
                historia.getIdExterno(),
                historia.getUrlOrigem(),
                historia.getDataCriacao(),
                historia.getDataAtualizacao());
    }

    private String tituloExibicao(Historia historia) {
        if (historia.getTituloPortugues() != null && !historia.getTituloPortugues().isBlank()) {
            return historia.getTituloPortugues();
        }

        if (historia.getTituloOriginal() != null && !historia.getTituloOriginal().isBlank()) {
            return historia.getTituloOriginal();
        }

        if (historia.getTitulo() != null && !historia.getTitulo().isBlank()) {
            return historia.getTitulo();
        }

        return "Título não disponível.";
    }

    private String descricaoExibicao(Historia historia) {
        if (historia.getDescricaoPortugues() != null && !historia.getDescricaoPortugues().isBlank()) {
            return historia.getDescricaoPortugues();
        }

        if (historia.getDescricaoOriginal() != null && !historia.getDescricaoOriginal().isBlank()) {
            return historia.getDescricaoOriginal();
        }

        if (historia.getDescricao() != null && !historia.getDescricao().isBlank()) {
            return historia.getDescricao();
        }

        return "Descrição não disponível.";
    }
}
