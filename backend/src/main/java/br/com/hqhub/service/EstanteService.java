package br.com.hqhub.service;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import br.com.hqhub.dto.EstanteEdicaoDTO;
import br.com.hqhub.dto.EstanteEditoraDTO;
import br.com.hqhub.dto.EstanteSerieDTO;
import br.com.hqhub.dto.PaginaRespostaDTO;
import br.com.hqhub.entity.Editora;
import br.com.hqhub.entity.ItemColecao;
import br.com.hqhub.entity.Serie;
import br.com.hqhub.entity.StatusLeitura;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.repository.ItemColecaoRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class EstanteService {

    private static final Pattern PRIMEIRO_NUMERO = Pattern.compile("\\d+");
    private static final Pattern SERIE_DESCRICAO = Pattern.compile("(\\d+)\\D{0,10}s.{0,2}rie", Pattern.CASE_INSENSITIVE);
    private static final List<String> ARTIGOS = List.of("a", "as", "o", "os");

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

        return montarEstantePorItens(itens);
    }

    @Transactional
    public List<EstanteEditoraDTO> montarEstantePublica(Long usuarioId) {
        List<ItemColecao> itens = itemColecaoRepository.list("usuario.id", usuarioId);
        return montarEstantePorItens(itens);
    }

    @Transactional
    public PaginaRespostaDTO<EstanteEditoraDTO> montarEstantePublicaPaginada(Long usuarioId, String busca, StatusLeitura statusLeitura, int pagina, int tamanho) {
        int paginaTratada = Math.max(pagina, 0);
        int tamanhoTratado = Math.min(Math.max(tamanho, 1), 100);
        long totalItens = itemColecaoRepository.contarPorUsuarioComFiltros(usuarioId, busca, statusLeitura);
        int totalPaginas = (int) Math.ceil((double) totalItens / tamanhoTratado);
        List<ItemColecao> itens = itemColecaoRepository.buscarPorUsuarioPaginado(
                usuarioId,
                busca,
                statusLeitura,
                paginaTratada,
                tamanhoTratado);
        return new PaginaRespostaDTO<>(
                montarEstantePorItens(itens),
                paginaTratada,
                tamanhoTratado,
                totalItens,
                totalPaginas);
    }

    @Transactional
    public PaginaRespostaDTO<EstanteEditoraDTO> montarEstantePaginada(String busca, StatusLeitura statusLeitura, int pagina, int tamanho) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        int paginaTratada = Math.max(pagina, 0);
        int tamanhoTratado = Math.min(Math.max(tamanho, 1), 100);
        long totalItens = itemColecaoRepository.contarPorUsuarioComFiltros(usuario.getId(), busca, statusLeitura);
        int totalPaginas = (int) Math.ceil((double) totalItens / tamanhoTratado);
        List<ItemColecao> itens = itemColecaoRepository.buscarPorUsuarioPaginado(
                usuario.getId(),
                busca,
                statusLeitura,
                paginaTratada,
                tamanhoTratado);

        return new PaginaRespostaDTO<>(
                montarEstantePorItens(itens),
                paginaTratada,
                tamanhoTratado,
                totalItens,
                totalPaginas);
    }

    private List<EstanteEditoraDTO> montarEstantePorItens(List<ItemColecao> itens) {
        Map<ChaveEditora, Map<ChaveSerie, List<ItemColecao>>> agrupado = itens.stream()
                .collect(Collectors.groupingBy(
                        item -> chaveEditora(item.getEdicao().getSerie().getEditora()),
                        Collectors.groupingBy(this::chaveSerie)));

        return agrupado.entrySet()
                .stream()
                .sorted(Comparator.comparing(entrada -> entrada.getKey().nome()))
                .map(this::montarEditora)
                .toList();
    }

    private EstanteEditoraDTO montarEditora(Map.Entry<ChaveEditora, Map<ChaveSerie, List<ItemColecao>>> entradaEditora) {
        Editora representante = entradaEditora.getValue().values().stream()
                .flatMap(List::stream)
                .map(item -> item.getEdicao().getSerie().getEditora())
                .min(Comparator.comparing(Editora::getId))
                .orElseThrow();

        return new EstanteEditoraDTO(
                representante.getId(),
                entradaEditora.getKey().nome(),
                montarSeries(entradaEditora.getValue()));
    }

    private List<EstanteSerieDTO> montarSeries(Map<ChaveSerie, List<ItemColecao>> series) {
        return series.entrySet()
                .stream()
                .sorted(Comparator.comparing((Map.Entry<ChaveSerie, List<ItemColecao>> entrada) -> entrada.getKey().tituloOrdenacao())
                        .thenComparing(entrada -> entrada.getKey().volume() == null ? 0 : entrada.getKey().volume()))
                .map(this::montarSerie)
                .toList();
    }

    private EstanteSerieDTO montarSerie(Map.Entry<ChaveSerie, List<ItemColecao>> entradaSerie) {
        Serie representante = entradaSerie.getValue().stream()
                .map(item -> item.getEdicao().getSerie())
                .min(Comparator.comparing(Serie::getId))
                .orElseThrow();

        return new EstanteSerieDTO(
                representante.getId(),
                representante.getTitulo(),
                entradaSerie.getKey().volume(),
                montarEdicoes(entradaSerie.getValue()));
    }

    private List<EstanteEdicaoDTO> montarEdicoes(List<ItemColecao> itens) {
        return itens.stream()
                .sorted(this::compararItemPorNumeroEdicao)
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

    private int compararItemPorNumeroEdicao(ItemColecao primeiro, ItemColecao segundo) {
        String numeroPrimeiro = primeiro.getEdicao().getNumero();
        String numeroSegundo = segundo.getEdicao().getNumero();
        int valorPrimeiro = extrairPrimeiroNumero(numeroPrimeiro);
        int valorSegundo = extrairPrimeiroNumero(numeroSegundo);

        if (valorPrimeiro != valorSegundo) {
            return Integer.compare(valorPrimeiro, valorSegundo);
        }

        return normalizarNumero(numeroPrimeiro).compareToIgnoreCase(normalizarNumero(numeroSegundo));
    }

    private int extrairPrimeiroNumero(String valor) {
        if (valor == null) {
            return Integer.MAX_VALUE;
        }

        Matcher matcher = PRIMEIRO_NUMERO.matcher(valor);
        return matcher.find() ? Integer.parseInt(matcher.group()) : Integer.MAX_VALUE;
    }

    private String normalizarNumero(String valor) {
        return valor == null ? "" : valor;
    }

    private ChaveEditora chaveEditora(Editora editora) {
        return new ChaveEditora(normalizarEditora(editora.getNome()), editora.getNome());
    }

    private ChaveSerie chaveSerie(ItemColecao item) {
        Serie serie = item.getEdicao().getSerie();
        Integer volume = volumeParaAgrupamento(item);
        return new ChaveSerie(normalizarTitulo(serie.getTitulo()), volume);
    }

    private Integer volumeParaAgrupamento(ItemColecao item) {
        Serie serie = item.getEdicao().getSerie();
        Integer volumeDescricao = extrairVolumeSerie(item.getEdicao().getDescricao());
        if (volumeDescricao != null) {
            return volumeDescricao;
        }

        if (serie.getVolume() != null) {
            return serie.getVolume();
        }

        return 1;
    }

    private Integer extrairVolumeSerie(String descricao) {
        if (descricao == null || descricao.isBlank()) {
            return null;
        }

        Matcher matcher = SERIE_DESCRICAO.matcher(descricao);
        return matcher.find() ? Integer.parseInt(matcher.group(1)) : null;
    }

    private String normalizarTitulo(String valor) {
        List<String> palavras = new ArrayList<>(List.of(normalizar(valor).split("\\s+")));
        palavras.removeIf(String::isBlank);

        while (!palavras.isEmpty() && ARTIGOS.contains(palavras.get(0))) {
            palavras.remove(0);
        }
        while (!palavras.isEmpty() && ARTIGOS.contains(palavras.get(palavras.size() - 1))) {
            palavras.remove(palavras.size() - 1);
        }

        return String.join(" ", palavras);
    }

    private String normalizarEditora(String valor) {
        List<String> palavras = new ArrayList<>(List.of(normalizar(valor).split("\\s+")));
        palavras.removeIf(palavra -> palavra.isBlank()
                || "editora".equals(palavra)
                || "editoras".equals(palavra)
                || "comic".equals(palavra)
                || "comics".equals(palavra)
                || "brasil".equals(palavra));

        return String.join(" ", palavras);
    }

    private String normalizar(String valor) {
        if (valor == null) {
            return "";
        }

        return Normalizer.normalize(valor.toLowerCase(Locale.ROOT), Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replaceAll("[^a-z0-9]+", " ")
                .trim();
    }

    private record ChaveEditora(String chave, String nome) {
    }

    private record ChaveSerie(String tituloOrdenacao, Integer volume) {
    }
}
