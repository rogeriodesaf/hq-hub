package br.com.hqhub.mapper;

import br.com.hqhub.dto.ConversaAssistenteRespostaDTO;
import br.com.hqhub.dto.MensagemAssistenteRespostaDTO;
import br.com.hqhub.entity.ConversaAssistente;
import br.com.hqhub.entity.MensagemAssistente;
import br.com.hqhub.entity.RemetenteMensagemAssistente;
import br.com.hqhub.entity.Usuario;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class AssistenteMapper {

    public ConversaAssistente paraConversa(String titulo, Usuario usuario) {
        ConversaAssistente conversa = new ConversaAssistente();
        conversa.setTitulo(titulo);
        conversa.setUsuario(usuario);
        return conversa;
    }

    public MensagemAssistente paraMensagem(
            ConversaAssistente conversa,
            RemetenteMensagemAssistente remetente,
            String conteudo,
            String origem,
            String dados) {
        MensagemAssistente mensagem = new MensagemAssistente();
        mensagem.setConversa(conversa);
        mensagem.setRemetente(remetente);
        mensagem.setConteudo(conteudo);
        mensagem.setOrigem(origem);
        mensagem.setDados(dados);
        return mensagem;
    }

    public ConversaAssistenteRespostaDTO paraResposta(ConversaAssistente conversa) {
        return new ConversaAssistenteRespostaDTO(
                conversa.getId(),
                conversa.getTitulo(),
                conversa.getDataCriacao(),
                conversa.getDataAtualizacao());
    }

    public MensagemAssistenteRespostaDTO paraResposta(MensagemAssistente mensagem) {
        return new MensagemAssistenteRespostaDTO(
                mensagem.getId(),
                mensagem.getRemetente(),
                mensagem.getConteudo(),
                mensagem.getOrigem(),
                mensagem.getDados(),
                mensagem.getDataCriacao());
    }
}
