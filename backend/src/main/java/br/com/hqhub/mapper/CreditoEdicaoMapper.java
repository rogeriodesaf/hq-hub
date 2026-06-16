package br.com.hqhub.mapper;

import br.com.hqhub.dto.CadastroCreditoEdicaoDTO;
import br.com.hqhub.dto.CreditoEdicaoRespostaDTO;
import br.com.hqhub.entity.CreditoEdicao;
import br.com.hqhub.entity.Criador;
import br.com.hqhub.entity.Edicao;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class CreditoEdicaoMapper {

    private final CriadorMapper criadorMapper;
    private final EdicaoMapper edicaoMapper;

    public CreditoEdicaoMapper(CriadorMapper criadorMapper, EdicaoMapper edicaoMapper) {
        this.criadorMapper = criadorMapper;
        this.edicaoMapper = edicaoMapper;
    }

    public CreditoEdicao paraEntidade(CadastroCreditoEdicaoDTO dto, Edicao edicao, Criador criador) {
        CreditoEdicao credito = new CreditoEdicao();
        credito.setEdicao(edicao);
        credito.setCriador(criador);
        credito.setPapel(dto.papel());
        credito.setObservacoes(dto.observacoes());
        return credito;
    }

    public CreditoEdicaoRespostaDTO paraResposta(CreditoEdicao credito) {
        return new CreditoEdicaoRespostaDTO(
                credito.getId(),
                criadorMapper.paraResposta(credito.getCriador()),
                edicaoMapper.paraResposta(credito.getEdicao()),
                credito.getPapel(),
                credito.getObservacoes());
    }
}
