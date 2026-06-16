package br.com.hqhub.mapper;

import br.com.hqhub.dto.CadastroRelacionamentoSerieDTO;
import br.com.hqhub.dto.EditoraResumoDTO;
import br.com.hqhub.dto.RelacionamentoSerieRespostaDTO;
import br.com.hqhub.dto.SerieResumoDTO;
import br.com.hqhub.entity.RelacionamentoSerie;
import br.com.hqhub.entity.Serie;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class RelacionamentoSerieMapper {

    public RelacionamentoSerie paraEntidade(CadastroRelacionamentoSerieDTO dto, Serie origem, Serie destino) {
        RelacionamentoSerie relacionamento = new RelacionamentoSerie();
        relacionamento.setSerieOrigem(origem);
        relacionamento.setSerieDestino(destino);
        relacionamento.setTipo(dto.tipo());
        relacionamento.setObservacoes(dto.observacoes());
        return relacionamento;
    }

    public RelacionamentoSerieRespostaDTO paraResposta(RelacionamentoSerie relacionamento) {
        return new RelacionamentoSerieRespostaDTO(
                relacionamento.getId(),
                paraResumo(relacionamento.getSerieOrigem()),
                paraResumo(relacionamento.getSerieDestino()),
                relacionamento.getTipo(),
                relacionamento.getObservacoes());
    }

    private SerieResumoDTO paraResumo(Serie serie) {
        return new SerieResumoDTO(
                serie.getId(),
                serie.getTitulo(),
                new EditoraResumoDTO(serie.getEditora().getId(), serie.getEditora().getNome()));
    }
}
