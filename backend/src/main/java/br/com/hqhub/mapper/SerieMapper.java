package br.com.hqhub.mapper;

import br.com.hqhub.dto.AtualizacaoSerieDTO;
import br.com.hqhub.dto.CadastroSerieDTO;
import br.com.hqhub.dto.EditoraResumoDTO;
import br.com.hqhub.dto.SerieRespostaDTO;
import br.com.hqhub.entity.Editora;
import br.com.hqhub.entity.Serie;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class SerieMapper {

    public Serie paraEntidade(CadastroSerieDTO dto, Editora editora) {
        Serie serie = new Serie();
        serie.setTitulo(dto.titulo());
        serie.setDescricao(dto.descricao());
        serie.setAnoInicio(dto.anoInicio());
        serie.setAnoFim(dto.anoFim());
        serie.setVolume(dto.volume());
        serie.setOrdemCronologica(dto.ordemCronologica());
        serie.setFonteExterna(dto.fonteExterna());
        serie.setIdExterno(dto.idExterno());
        serie.setUrlOrigem(dto.urlOrigem());
        serie.setEditora(editora);
        return serie;
    }

    public void atualizarEntidade(Serie serie, AtualizacaoSerieDTO dto, Editora editora) {
        serie.setTitulo(dto.titulo());
        serie.setDescricao(dto.descricao());
        serie.setAnoInicio(dto.anoInicio());
        serie.setAnoFim(dto.anoFim());
        serie.setVolume(dto.volume());
        serie.setOrdemCronologica(dto.ordemCronologica());
        serie.setFonteExterna(dto.fonteExterna());
        serie.setIdExterno(dto.idExterno());
        serie.setUrlOrigem(dto.urlOrigem());
        serie.setEditora(editora);
    }

    public SerieRespostaDTO paraResposta(Serie serie) {
        return new SerieRespostaDTO(
                serie.getId(),
                serie.getTitulo(),
                serie.getDescricao(),
                serie.getAnoInicio(),
                serie.getAnoFim(),
                serie.getVolume(),
                serie.getOrdemCronologica(),
                serie.getFonteExterna(),
                serie.getIdExterno(),
                serie.getUrlOrigem(),
                new EditoraResumoDTO(serie.getEditora().getId(), serie.getEditora().getNome()),
                serie.getDataCriacao(),
                serie.getDataAtualizacao());
    }
}
