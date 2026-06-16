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
                historia.getDescricao(),
                historia.getQuantidadePaginas(),
                historia.getTipo(),
                historia.getFonteExterna(),
                historia.getIdExterno(),
                historia.getUrlOrigem(),
                historia.getDataCriacao(),
                historia.getDataAtualizacao());
    }
}
