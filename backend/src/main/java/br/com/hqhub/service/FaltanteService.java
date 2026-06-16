package br.com.hqhub.service;

import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import br.com.hqhub.dto.EdicaoRespostaDTO;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.mapper.EdicaoMapper;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.ItemColecaoRepository;
import br.com.hqhub.repository.SerieRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class FaltanteService {

    private final SerieRepository serieRepository;
    private final EdicaoRepository edicaoRepository;
    private final ItemColecaoRepository itemColecaoRepository;
    private final EdicaoMapper edicaoMapper;
    private final UsuarioAutenticadoService usuarioAutenticadoService;

    public FaltanteService(
            SerieRepository serieRepository,
            EdicaoRepository edicaoRepository,
            ItemColecaoRepository itemColecaoRepository,
            EdicaoMapper edicaoMapper,
            UsuarioAutenticadoService usuarioAutenticadoService) {
        this.serieRepository = serieRepository;
        this.edicaoRepository = edicaoRepository;
        this.itemColecaoRepository = itemColecaoRepository;
        this.edicaoMapper = edicaoMapper;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
    }

    @Transactional
    public List<EdicaoRespostaDTO> listarFaltantesPorSerie(Long serieId) {
        if (serieRepository.findByIdOptional(serieId).isEmpty()) {
            throw new RecursoNaoEncontradoException("Série não encontrada.");
        }

        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        Set<Long> idsEdicoesNaColecao = new HashSet<>(
                itemColecaoRepository.listarIdsEdicoesPorUsuarioESerie(usuario.getId(), serieId));

        return edicaoRepository.list("serie.id", serieId)
                .stream()
                .filter(edicao -> !idsEdicoesNaColecao.contains(edicao.getId()))
                .sorted(Comparator.comparing(Edicao::getNumero))
                .map(edicaoMapper::paraResposta)
                .toList();
    }
}
