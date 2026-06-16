package br.com.hqhub.mapper;

import br.com.hqhub.dto.AtualizacaoCriadorDTO;
import br.com.hqhub.dto.CadastroCriadorDTO;
import br.com.hqhub.dto.CriadorRespostaDTO;
import br.com.hqhub.entity.Criador;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class CriadorMapper {

    public Criador paraEntidade(CadastroCriadorDTO dto) {
        Criador criador = new Criador();
        criador.setNome(dto.nome());
        criador.setNomeArtistico(dto.nomeArtistico());
        criador.setFonteExterna(dto.fonteExterna());
        criador.setIdExterno(dto.idExterno());
        criador.setUrlOrigem(dto.urlOrigem());
        return criador;
    }

    public void atualizarEntidade(Criador criador, AtualizacaoCriadorDTO dto) {
        criador.setNome(dto.nome());
        criador.setNomeArtistico(dto.nomeArtistico());
        criador.setFonteExterna(dto.fonteExterna());
        criador.setIdExterno(dto.idExterno());
        criador.setUrlOrigem(dto.urlOrigem());
    }

    public CriadorRespostaDTO paraResposta(Criador criador) {
        return new CriadorRespostaDTO(
                criador.getId(),
                criador.getNome(),
                criador.getNomeArtistico(),
                criador.getFonteExterna(),
                criador.getIdExterno(),
                criador.getUrlOrigem(),
                criador.getDataCriacao(),
                criador.getDataAtualizacao());
    }
}
