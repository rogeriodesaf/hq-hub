package br.com.hqhub.mapper;

import br.com.hqhub.dto.AtualizacaoEdicaoDTO;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.Editora;
import br.com.hqhub.entity.Serie;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class EdicaoMapperTest {
    private final EdicaoMapper mapper = new EdicaoMapper();

    private Edicao edicao() {
        Serie serie = new Serie();
        serie.setEditora(new Editora());
        Edicao edicao = new Edicao();
        edicao.setSerie(serie);
        edicao.setDescricao("Original anterior");
        edicao.setDescricaoOriginal("Original anterior");
        edicao.setDescricaoPortugues("Traducao anterior");
        return edicao;
    }

    private AtualizacaoEdicaoDTO atualizacao(String descricao) {
        return new AtualizacaoEdicaoDTO("1", null, descricao, null, null,
                null, null, null, null, null, null, null, 1L);
    }

    @Test
    void descricaoEditadaApareceNaRespostaDoModal() {
        Edicao edicao = edicao();
        mapper.atualizarEntidade(edicao, atualizacao("Descricao corrigida"), edicao.getSerie());
        assertNull(edicao.getDescricaoPortugues());
        assertEquals("Descricao corrigida", mapper.paraResposta(edicao).descricaoExibicao());
        assertEquals("Descricao corrigida", mapper.paraResposta(edicao).descricao());
    }

    @Test
    void alterarOutrosCamposPreservaTraducao() {
        Edicao edicao = edicao();
        mapper.atualizarEntidade(edicao, atualizacao("Original anterior"), edicao.getSerie());
        assertEquals("Traducao anterior", mapper.paraResposta(edicao).descricaoExibicao());
    }

    @Test
    void apagarDescricaoNaoRestauraTraducaoAntiga() {
        Edicao edicao = edicao();
        mapper.atualizarEntidade(edicao, atualizacao(null), edicao.getSerie());
        assertNull(mapper.paraResposta(edicao).descricaoPortugues());
        assertNull(mapper.paraResposta(edicao).descricaoOriginal());
        assertNotEquals("Traducao anterior", mapper.paraResposta(edicao).descricaoExibicao());
    }
}
