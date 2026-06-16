package br.com.hqhub.mapper;

import br.com.hqhub.dto.CadastroSolicitacaoImportacaoDTO;
import br.com.hqhub.dto.SolicitacaoImportacaoRespostaDTO;
import br.com.hqhub.entity.SolicitacaoImportacao;
import br.com.hqhub.entity.StatusSolicitacaoImportacao;
import br.com.hqhub.entity.Usuario;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class SolicitacaoImportacaoMapper {

    public SolicitacaoImportacao paraEntidade(CadastroSolicitacaoImportacaoDTO dto, Usuario usuario) {
        SolicitacaoImportacao solicitacao = new SolicitacaoImportacao();
        solicitacao.setUsuario(usuario);
        solicitacao.setFonteExterna(dto.fonteExterna());
        solicitacao.setTermo(dto.termo());
        solicitacao.setUrlOrigem(dto.urlOrigem());
        solicitacao.setStatus(StatusSolicitacaoImportacao.PENDENTE);
        solicitacao.setMensagem("Solicitação registrada para processamento em segundo plano.");
        return solicitacao;
    }

    public SolicitacaoImportacaoRespostaDTO paraResposta(SolicitacaoImportacao solicitacao) {
        return new SolicitacaoImportacaoRespostaDTO(
                solicitacao.getId(),
                solicitacao.getFonteExterna(),
                solicitacao.getTermo(),
                solicitacao.getUrlOrigem(),
                solicitacao.getStatus(),
                solicitacao.getMensagem(),
                solicitacao.getResultadoJson(),
                solicitacao.getDataProcessamento(),
                solicitacao.getDataCriacao(),
                solicitacao.getDataAtualizacao());
    }
}
