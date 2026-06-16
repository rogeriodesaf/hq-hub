package br.com.hqhub.service;

import java.util.List;

import br.com.hqhub.dto.AtualizacaoCriadorDTO;
import br.com.hqhub.dto.CadastroCriadorDTO;
import br.com.hqhub.dto.CriadorRespostaDTO;
import br.com.hqhub.entity.Criador;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.CriadorMapper;
import br.com.hqhub.repository.CriadorRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class CriadorService {

    private final CriadorRepository criadorRepository;
    private final CriadorMapper criadorMapper;

    public CriadorService(CriadorRepository criadorRepository, CriadorMapper criadorMapper) {
        this.criadorRepository = criadorRepository;
        this.criadorMapper = criadorMapper;
    }

    @Transactional
    public CriadorRespostaDTO cadastrar(CadastroCriadorDTO dto) {
        if (criadorRepository.existePorNome(dto.nome())) {
            throw new RegraNegocioException("Já existe um criador cadastrado com este nome.");
        }

        Criador criador = criadorMapper.paraEntidade(dto);
        criadorRepository.persist(criador);

        return criadorMapper.paraResposta(criador);
    }

    @Transactional
    public CriadorRespostaDTO atualizar(Long id, AtualizacaoCriadorDTO dto) {
        Criador criador = buscarEntidadePorId(id);

        if (criadorRepository.existePorNomeEmOutroCriador(dto.nome(), id)) {
            throw new RegraNegocioException("Já existe um criador cadastrado com este nome.");
        }

        criadorMapper.atualizarEntidade(criador, dto);

        return criadorMapper.paraResposta(criador);
    }

    public CriadorRespostaDTO buscarPorId(Long id) {
        return criadorMapper.paraResposta(buscarEntidadePorId(id));
    }

    public List<CriadorRespostaDTO> listar(String nome) {
        List<Criador> criadores = nome == null || nome.isBlank()
                ? criadorRepository.list("nome")
                : criadorRepository.list("lower(nome) like ?1 or lower(nomeArtistico) like ?1", "%" + nome.toLowerCase() + "%");

        return criadores.stream().map(criadorMapper::paraResposta).toList();
    }

    @Transactional
    public void remover(Long id) {
        Criador criador = buscarEntidadePorId(id);
        criadorRepository.delete(criador);
    }

    private Criador buscarEntidadePorId(Long id) {
        return criadorRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Criador não encontrado."));
    }
}
