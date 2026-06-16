package br.com.hqhub.mapper;

import br.com.hqhub.dto.CadastroContribuicaoCatalogoDTO;
import br.com.hqhub.dto.ContribuicaoCatalogoRespostaDTO;
import br.com.hqhub.entity.ContribuicaoCatalogo;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.StatusContribuicaoCatalogo;
import br.com.hqhub.entity.Usuario;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ContribuicaoCatalogoMapper {

    private final UsuarioMapper usuarioMapper;
    private final EdicaoMapper edicaoMapper;

    public ContribuicaoCatalogoMapper(UsuarioMapper usuarioMapper, EdicaoMapper edicaoMapper) {
        this.usuarioMapper = usuarioMapper;
        this.edicaoMapper = edicaoMapper;
    }

    public ContribuicaoCatalogo paraEntidade(CadastroContribuicaoCatalogoDTO dto, Usuario usuario, Edicao edicao) {
        ContribuicaoCatalogo contribuicao = new ContribuicaoCatalogo();
        contribuicao.setUsuario(usuario);
        contribuicao.setEdicao(edicao);
        contribuicao.setTipo(dto.tipo());
        contribuicao.setStatus(StatusContribuicaoCatalogo.PENDENTE);
        contribuicao.setUrlCapaSugerida(dto.urlCapaSugerida());
        contribuicao.setEdicaoDestinoId(dto.edicaoDestinoId());
        contribuicao.setTipoPublicacaoRelacionada(dto.tipoPublicacaoRelacionada());
        contribuicao.setFonteExterna(dto.fonteExterna());
        contribuicao.setUrlFonte(dto.urlFonte());
        contribuicao.setDadosSugeridosJson(dto.dadosSugeridosJson());
        contribuicao.setObservacoes(dto.observacoes());
        return contribuicao;
    }

    public ContribuicaoCatalogoRespostaDTO paraResposta(ContribuicaoCatalogo contribuicao) {
        return new ContribuicaoCatalogoRespostaDTO(
                contribuicao.getId(),
                usuarioMapper.paraResposta(contribuicao.getUsuario()),
                edicaoMapper.paraResposta(contribuicao.getEdicao()),
                contribuicao.getTipo(),
                contribuicao.getStatus(),
                contribuicao.getUrlCapaSugerida(),
                contribuicao.getEdicaoDestinoId(),
                contribuicao.getTipoPublicacaoRelacionada(),
                contribuicao.getFonteExterna(),
                contribuicao.getUrlFonte(),
                contribuicao.getDadosSugeridosJson(),
                contribuicao.getObservacoes(),
                contribuicao.getMensagemRevisao(),
                contribuicao.getDataRevisao(),
                contribuicao.getDataCriacao(),
                contribuicao.getDataAtualizacao());
    }
}
