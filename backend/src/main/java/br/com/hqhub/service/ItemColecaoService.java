package br.com.hqhub.service;

import java.math.BigDecimal;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.StringJoiner;

import br.com.hqhub.dto.AtualizacaoItemColecaoDTO;
import br.com.hqhub.dto.CadastroItemColecaoDTO;
import br.com.hqhub.dto.ItemColecaoRespostaDTO;
import br.com.hqhub.entity.ContribuicaoCatalogo;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.ItemColecao;
import br.com.hqhub.entity.StatusContribuicaoCatalogo;
import br.com.hqhub.entity.TipoContribuicaoCatalogo;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.ItemColecaoMapper;
import br.com.hqhub.repository.ContribuicaoCatalogoRepository;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.ItemColecaoRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.persistence.EntityManager;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class ItemColecaoService {

    private final ItemColecaoRepository itemColecaoRepository;
    private final EdicaoRepository edicaoRepository;
    private final ItemColecaoMapper itemColecaoMapper;
    private final UsuarioAutenticadoService usuarioAutenticadoService;
    private final EntityManager entityManager;
    private final ContribuicaoCatalogoRepository contribuicaoCatalogoRepository;

    public ItemColecaoService(
            ItemColecaoRepository itemColecaoRepository,
            EdicaoRepository edicaoRepository,
            ItemColecaoMapper itemColecaoMapper,
            UsuarioAutenticadoService usuarioAutenticadoService,
            EntityManager entityManager,
            ContribuicaoCatalogoRepository contribuicaoCatalogoRepository) {
        this.itemColecaoRepository = itemColecaoRepository;
        this.edicaoRepository = edicaoRepository;
        this.itemColecaoMapper = itemColecaoMapper;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
        this.entityManager = entityManager;
        this.contribuicaoCatalogoRepository = contribuicaoCatalogoRepository;
    }

    @Transactional
    public ItemColecaoRespostaDTO cadastrar(CadastroItemColecaoDTO dto) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        Edicao edicao = buscarEdicaoPorId(dto.edicaoId());

        if (itemColecaoRepository.existePorUsuarioEEdicao(usuario.getId(), dto.edicaoId())) {
            throw new RegraNegocioException("Esta edicao ja esta na sua colecao.");
        }

        ItemColecao item = itemColecaoMapper.paraEntidade(dto, usuario, edicao);
        itemColecaoRepository.persist(item);
        registrarRevisaoEstante(usuario, item, "ITEM_ADICIONADO", montarDadosItemJson(item, null));

        return itemColecaoMapper.paraResposta(item);
    }

    @Transactional
    public ItemColecaoRespostaDTO atualizar(Long id, AtualizacaoItemColecaoDTO dto) {
        ItemColecao item = buscarItemDoUsuarioPorId(id);
        String antes = montarDadosItemJson(item, null);
        itemColecaoMapper.atualizarEntidade(item, dto);
        registrarRevisaoEstante(item.getUsuario(), item, "ITEM_ATUALIZADO", montarDadosItemJson(item, antes));

        return itemColecaoMapper.paraResposta(item);
    }

    @Transactional
    public ItemColecaoRespostaDTO buscarPorId(Long id) {
        return itemColecaoMapper.paraResposta(buscarItemDoUsuarioPorId(id));
    }

    @Transactional
    public List<ItemColecaoRespostaDTO> listarTodos() {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();

        return itemColecaoRepository.list("usuario.id", usuario.getId())
                .stream()
                .sorted(Comparator.comparing((ItemColecao item) -> item.getEdicao().getSerie().getTitulo())
                        .thenComparing(item -> item.getEdicao().getNumero()))
                .map(itemColecaoMapper::paraResposta)
                .toList();
    }

    @Transactional
    public Optional<ItemColecaoRespostaDTO> buscarPorOrigemExterna(String fonteExterna, String idExterno) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();

        return itemColecaoRepository.buscarPorUsuarioEOrigemExterna(usuario.getId(), fonteExterna, idExterno)
                .map(itemColecaoMapper::paraResposta);
    }

    @Transactional
    public void remover(Long id) {
        ItemColecao item = buscarItemDoUsuarioPorId(id);
        removerDependenciasDoItem(item.getId());
        itemColecaoRepository.delete(item);
    }

    @Transactional
    public String exportarColecao(String formato) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        boolean googleSheets = "GOOGLE".equalsIgnoreCase(formato);
        char separador = googleSheets ? ',' : ';';
        List<ItemColecao> itens = itemColecaoRepository.buscarPorUsuarioParaExportacao(usuario.getId());

        StringBuilder csv = new StringBuilder();
        if (!googleSheets) {
            csv.append('\ufeff');
            csv.append("sep=;").append('\n');
        }
        adicionarLinhaCsv(csv, separador, List.of(
                "Editora",
                "Serie",
                "Volume",
                "Numero",
                "Titulo da edicao",
                "Formato",
                "Estado de conservacao",
                "Status de leitura",
                "Data de aquisicao",
                "Preco pago",
                "Observacoes",
                "URL da capa",
                "URL de origem"));

        for (ItemColecao item : itens) {
            Edicao edicao = item.getEdicao();
            adicionarLinhaCsv(csv, separador, List.of(
                    valorCsv(edicao.getSerie().getEditora().getNome()),
                    valorCsv(edicao.getSerie().getTitulo()),
                    valorCsv(edicao.getSerie().getVolume()),
                    valorCsv(edicao.getNumero()),
                    valorCsv(edicao.getTitulo()),
                    valorCsv(edicao.getFormato()),
                    valorCsv(item.getEstadoConservacao()),
                    valorCsv(item.getStatusLeitura()),
                    valorCsv(item.getDataAquisicao()),
                    valorCsv(item.getPrecoPago()),
                    valorCsv(item.getObservacoes()),
                    valorCsv(edicao.getUrlCapa()),
                    valorCsv(edicao.getUrlOrigem())));
        }

        return csv.toString();
    }

    private void removerDependenciasDoItem(Long itemColecaoId) {
        entityManager.createNativeQuery("""
                delete from denuncias_anuncios denuncia
                 using anuncios anuncio
                 where denuncia.anuncio_id = anuncio.id
                   and anuncio.item_colecao_id = :itemColecaoId
                """)
                .setParameter("itemColecaoId", itemColecaoId)
                .executeUpdate();

        entityManager.createNativeQuery("""
                delete from fotos_anuncios foto
                 using anuncios anuncio
                 where foto.anuncio_id = anuncio.id
                   and anuncio.item_colecao_id = :itemColecaoId
                """)
                .setParameter("itemColecaoId", itemColecaoId)
                .executeUpdate();

        entityManager.createNativeQuery("delete from anuncios where item_colecao_id = :itemColecaoId")
                .setParameter("itemColecaoId", itemColecaoId)
                .executeUpdate();
    }

    private ItemColecao buscarItemDoUsuarioPorId(Long id) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();

        return itemColecaoRepository.find("id = ?1 and usuario.id = ?2", id, usuario.getId())
                .firstResultOptional()
                .orElseThrow(() -> new RecursoNaoEncontradoException("Item da colecao nao encontrado."));
    }

    private Edicao buscarEdicaoPorId(Long id) {
        return edicaoRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Edicao nao encontrada."));
    }

    private void registrarRevisaoEstante(Usuario usuario, ItemColecao item, String origem, String dadosSugeridosJson) {
        ContribuicaoCatalogo contribuicao = new ContribuicaoCatalogo();
        contribuicao.setUsuario(usuario);
        contribuicao.setEdicao(item.getEdicao());
        contribuicao.setTipo(TipoContribuicaoCatalogo.DADOS_EDICAO);
        contribuicao.setStatus(StatusContribuicaoCatalogo.PENDENTE);
        contribuicao.setFonteExterna("ALTERACAO_ESTANTE");
        contribuicao.setDadosSugeridosJson(dadosSugeridosJson);
        contribuicao.setObservacoes("Alteracao na estante do usuario: " + origem
                + ". Conferir se a HQ precisa de dados adicionais no catalogo.");
        contribuicaoCatalogoRepository.persist(contribuicao);
    }

    private String montarDadosItemJson(ItemColecao item, String antes) {
        StringBuilder json = new StringBuilder("{");
        adicionarCampoJson(json, "itemColecaoId", item.getId());
        adicionarCampoJson(json, "edicaoId", item.getEdicao().getId());
        adicionarCampoJson(json, "estadoConservacao", item.getEstadoConservacao());
        adicionarCampoJson(json, "statusLeitura", item.getStatusLeitura());
        adicionarCampoJson(json, "dataAquisicao", item.getDataAquisicao());
        adicionarCampoJson(json, "precoPago", item.getPrecoPago());
        adicionarCampoJson(json, "observacoes", item.getObservacoes());
        if (antes != null) {
            json.append(",\"antes\":").append(antes);
        }
        json.append('}');
        return json.toString();
    }

    private void adicionarCampoJson(StringBuilder json, String nome, Object valor) {
        if (json.length() > 1) {
            json.append(',');
        }
        json.append('"').append(nome).append("\":");
        if (valor == null) {
            json.append("null");
            return;
        }
        if (valor instanceof Number || valor instanceof Boolean) {
            json.append(valor);
            return;
        }
        json.append('"').append(escaparJson(String.valueOf(valor))).append('"');
    }

    private String escaparJson(String valor) {
        return valor.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private void adicionarLinhaCsv(StringBuilder csv, char separador, List<String> valores) {
        StringJoiner linha = new StringJoiner(String.valueOf(separador));
        valores.forEach(valor -> linha.add(escaparCsv(valor, separador)));
        csv.append(linha).append('\n');
    }

    private String escaparCsv(String valor, char separador) {
        String texto = valor == null ? "" : valor;
        boolean precisaAspas = texto.indexOf(separador) >= 0
                || texto.contains("\"")
                || texto.contains("\n")
                || texto.contains("\r");
        texto = texto.replace("\"", "\"\"");
        return precisaAspas ? "\"" + texto + "\"" : texto;
    }

    private String valorCsv(Object valor) {
        if (valor == null) {
            return "";
        }
        if (valor instanceof BigDecimal decimal) {
            return decimal.toPlainString();
        }
        return String.valueOf(valor);
    }
}
