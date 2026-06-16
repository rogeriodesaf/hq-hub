package br.com.hqhub.mapper;

import br.com.hqhub.dto.AtualizacaoColecaoSerieDTO;
import br.com.hqhub.dto.CadastroColecaoSerieDTO;
import br.com.hqhub.dto.ColecaoSerieRespostaDTO;
import br.com.hqhub.dto.EditoraResumoDTO;
import br.com.hqhub.dto.SerieResumoDTO;
import br.com.hqhub.entity.ColecaoSerie;
import br.com.hqhub.entity.Serie;
import br.com.hqhub.entity.Usuario;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ColecaoSerieMapper {

    public ColecaoSerie paraEntidade(CadastroColecaoSerieDTO dto, Usuario usuario, Serie serie) {
        ColecaoSerie colecaoSerie = new ColecaoSerie();
        colecaoSerie.setUsuario(usuario);
        colecaoSerie.setSerie(serie);
        colecaoSerie.setStatus(dto.status());
        colecaoSerie.setPrioridade(dto.prioridade());
        colecaoSerie.setObservacoes(dto.observacoes());
        return colecaoSerie;
    }

    public void atualizarEntidade(ColecaoSerie colecaoSerie, AtualizacaoColecaoSerieDTO dto) {
        colecaoSerie.setStatus(dto.status());
        colecaoSerie.setPrioridade(dto.prioridade());
        colecaoSerie.setObservacoes(dto.observacoes());
    }

    public ColecaoSerieRespostaDTO paraResposta(ColecaoSerie colecaoSerie) {
        Serie serie = colecaoSerie.getSerie();

        return new ColecaoSerieRespostaDTO(
                colecaoSerie.getId(),
                new SerieResumoDTO(
                        serie.getId(),
                        serie.getTitulo(),
                        new EditoraResumoDTO(serie.getEditora().getId(), serie.getEditora().getNome())),
                colecaoSerie.getStatus(),
                colecaoSerie.getPrioridade(),
                colecaoSerie.getObservacoes(),
                colecaoSerie.getDataCriacao(),
                colecaoSerie.getDataAtualizacao());
    }
}
