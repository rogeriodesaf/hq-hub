package br.com.hqhub.mapper;

import br.com.hqhub.dto.ConfiguracaoColecaoRespostaDTO;
import br.com.hqhub.entity.ConfiguracaoColecao;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.entity.VisibilidadeColecao;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ConfiguracaoColecaoMapper {

    public ConfiguracaoColecao paraEntidade(Usuario usuario) {
        ConfiguracaoColecao configuracao = new ConfiguracaoColecao();
        configuracao.setUsuario(usuario);
        configuracao.setVisibilidadeColecao(VisibilidadeColecao.PRIVADA);
        return configuracao;
    }

    public ConfiguracaoColecaoRespostaDTO paraResposta(ConfiguracaoColecao configuracao) {
        return new ConfiguracaoColecaoRespostaDTO(
                configuracao.getId(),
                configuracao.getVisibilidadeColecao(),
                configuracao.getDataCriacao(),
                configuracao.getDataAtualizacao());
    }
}
