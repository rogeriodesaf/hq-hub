package br.com.hqhub.service;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import br.com.hqhub.dto.EstanteEdicaoDTO;
import br.com.hqhub.dto.EstanteEditoraDTO;
import br.com.hqhub.dto.EstanteSerieDTO;
import br.com.hqhub.entity.Editora;
import br.com.hqhub.entity.ItemColecao;
import br.com.hqhub.entity.Serie;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.repository.ItemColecaoRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class EstanteService {

    private final ItemColecaoRepository itemColecaoRepository;
    private final UsuarioAutenticadoService usuarioAutenticadoService;

    public EstanteService(ItemColecaoRepository itemColecaoRepository, UsuarioAutenticadoService usuarioAutenticadoService) {
        this.itemColecaoRepository = itemColecaoRepository;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
    }

    @Transactional
    public List<EstanteEditoraDTO> montarEstante() {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        List<ItemColecao> itens = itemColecaoRepository.list("usuario.id", usuario.getId());

        Map<Editora, Map<Serie, List<ItemColecao>>> agrupado = itens.stream()
                .collect(Collectors.groupingBy(
                        item -> item.getEdicao().getSerie().getEditora(),
                        Collectors.groupingBy(item -> item.getEdicao().getSerie())));

        return agrupado.entrySet()
                .stream()
                .sorted(Comparator.comparing(entrada -> entrada.getKey().getNome()))
                .map(entradaEditora -> new EstanteEditoraDTO(
                        entradaEditora.getKey().getId(),
                        entradaEditora.getKey().getNome(),
                        montarSeries(entradaEditora.getValue())))
                .toList();
    }

    private List<EstanteSerieDTO> montarSeries(Map<Serie, List<ItemColecao>> series) {
        return series.entrySet()
                .stream()
                .sorted(Comparator.comparing(entrada -> entrada.getKey().getTitulo()))
                .map(entradaSerie -> new EstanteSerieDTO(
                        entradaSerie.getKey().getId(),
                        entradaSerie.getKey().getTitulo(),
                        montarEdicoes(entradaSerie.getValue())))
                .toList();
    }

    private List<EstanteEdicaoDTO> montarEdicoes(List<ItemColecao> itens) {
        return itens.stream()
                .sorted(Comparator.comparing(item -> item.getEdicao().getNumero()))
                .map(item -> new EstanteEdicaoDTO(
                        item.getId(),
                        item.getEdicao().getId(),
                        item.getEdicao().getNumero(),
                        item.getEdicao().getTitulo(),
                        item.getEdicao().getUrlCapa(),
                        item.getEstadoConservacao(),
                        item.getStatusLeitura(),
                        item.getDataAquisicao(),
                        item.getPrecoPago()))
                .toList();
    }
}
