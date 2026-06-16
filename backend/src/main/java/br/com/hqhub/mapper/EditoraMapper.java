package br.com.hqhub.mapper;

import br.com.hqhub.dto.AtualizacaoEditoraDTO;
import br.com.hqhub.dto.CadastroEditoraDTO;
import br.com.hqhub.dto.EditoraRespostaDTO;
import br.com.hqhub.entity.Editora;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class EditoraMapper {

    public Editora paraEntidade(CadastroEditoraDTO dto) {
        Editora editora = new Editora();
        editora.setNome(dto.nome());
        editora.setDescricao(dto.descricao());
        editora.setPaisOrigem(dto.paisOrigem());
        editora.setFonteExterna(dto.fonteExterna());
        editora.setIdExterno(dto.idExterno());
        editora.setUrlOrigem(dto.urlOrigem());
        return editora;
    }

    public void atualizarEntidade(Editora editora, AtualizacaoEditoraDTO dto) {
        editora.setNome(dto.nome());
        editora.setDescricao(dto.descricao());
        editora.setPaisOrigem(dto.paisOrigem());
        editora.setFonteExterna(dto.fonteExterna());
        editora.setIdExterno(dto.idExterno());
        editora.setUrlOrigem(dto.urlOrigem());
    }

    public EditoraRespostaDTO paraResposta(Editora editora) {
        return new EditoraRespostaDTO(
                editora.getId(),
                editora.getNome(),
                editora.getDescricao(),
                editora.getPaisOrigem(),
                editora.getFonteExterna(),
                editora.getIdExterno(),
                editora.getUrlOrigem(),
                editora.getDataCriacao(),
                editora.getDataAtualizacao());
    }
}
