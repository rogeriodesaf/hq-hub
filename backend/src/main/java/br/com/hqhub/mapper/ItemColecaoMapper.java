package br.com.hqhub.mapper;

import br.com.hqhub.dto.AtualizacaoItemColecaoDTO;
import br.com.hqhub.dto.CadastroItemColecaoDTO;
import br.com.hqhub.dto.ItemColecaoRespostaDTO;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.ItemColecao;
import br.com.hqhub.entity.StatusLeitura;
import br.com.hqhub.entity.Usuario;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ItemColecaoMapper {

    private final EdicaoMapper edicaoMapper;

    public ItemColecaoMapper(EdicaoMapper edicaoMapper) {
        this.edicaoMapper = edicaoMapper;
    }

    public ItemColecao paraEntidade(CadastroItemColecaoDTO dto, Usuario usuario, Edicao edicao) {
        ItemColecao item = new ItemColecao();
        item.setUsuario(usuario);
        item.setEdicao(edicao);
        item.setEstadoConservacao(dto.estadoConservacao());
        item.setDataAquisicao(dto.dataAquisicao());
        item.setPrecoPago(dto.precoPago() == null ? edicao.getPrecoCapa() : dto.precoPago());
        item.setStatusLeitura(dto.statusLeitura() == null ? StatusLeitura.NAO_LIDO : dto.statusLeitura());
        item.setObservacoes(dto.observacoes());
        return item;
    }

    public void atualizarEntidade(ItemColecao item, AtualizacaoItemColecaoDTO dto) {
        item.setEstadoConservacao(dto.estadoConservacao());
        item.setDataAquisicao(dto.dataAquisicao());
        item.setPrecoPago(dto.precoPago());
        item.setStatusLeitura(dto.statusLeitura() == null ? StatusLeitura.NAO_LIDO : dto.statusLeitura());
        item.setObservacoes(dto.observacoes());
    }

    public ItemColecaoRespostaDTO paraResposta(ItemColecao item) {
        return new ItemColecaoRespostaDTO(
                item.getId(),
                edicaoMapper.paraResposta(item.getEdicao()),
                item.getEstadoConservacao(),
                item.getDataAquisicao(),
                item.getPrecoPago(),
                item.getStatusLeitura(),
                item.getObservacoes(),
                item.getDataCriacao(),
                item.getDataAtualizacao());
    }
}
