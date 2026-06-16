package br.com.hqhub.mapper;

import br.com.hqhub.dto.AtualizacaoCompraPlanejadaDTO;
import br.com.hqhub.dto.CadastroCompraPlanejadaDTO;
import br.com.hqhub.dto.CompraPlanejadaRespostaDTO;
import br.com.hqhub.entity.CompraPlanejada;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.PrioridadeCompra;
import br.com.hqhub.entity.StatusCompraPlanejada;
import br.com.hqhub.entity.Usuario;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class CompraPlanejadaMapper {

    private final EdicaoMapper edicaoMapper;

    public CompraPlanejadaMapper(EdicaoMapper edicaoMapper) {
        this.edicaoMapper = edicaoMapper;
    }

    public CompraPlanejada paraEntidade(CadastroCompraPlanejadaDTO dto, Usuario usuario, Edicao edicao) {
        CompraPlanejada compra = new CompraPlanejada();
        compra.setUsuario(usuario);
        compra.setEdicao(edicao);
        compra.setMes(dto.mes());
        compra.setAno(dto.ano());
        compra.setStatus(dto.status() == null ? StatusCompraPlanejada.PLANEJADA : dto.status());
        compra.setPrioridade(dto.prioridade() == null ? PrioridadeCompra.MEDIA : dto.prioridade());
        compra.setPrecoEstimado(dto.precoEstimado());
        compra.setLinkCompra(dto.linkCompra());
        compra.setObservacoes(dto.observacoes());
        return compra;
    }

    public void atualizarEntidade(CompraPlanejada compra, AtualizacaoCompraPlanejadaDTO dto) {
        compra.setMes(dto.mes());
        compra.setAno(dto.ano());
        compra.setStatus(dto.status());
        compra.setPrioridade(dto.prioridade());
        compra.setPrecoEstimado(dto.precoEstimado());
        compra.setLinkCompra(dto.linkCompra());
        compra.setObservacoes(dto.observacoes());
    }

    public CompraPlanejadaRespostaDTO paraResposta(CompraPlanejada compra) {
        return new CompraPlanejadaRespostaDTO(
                compra.getId(),
                edicaoMapper.paraResposta(compra.getEdicao()),
                compra.getMes(),
                compra.getAno(),
                compra.getStatus(),
                compra.getPrioridade(),
                compra.getPrecoEstimado(),
                compra.getLinkCompra(),
                compra.getObservacoes(),
                compra.getDataCriacao(),
                compra.getDataAtualizacao());
    }
}
