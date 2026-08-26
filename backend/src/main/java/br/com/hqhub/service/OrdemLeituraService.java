package br.com.hqhub.service;

import java.time.LocalDateTime;
import java.util.*;
import br.com.hqhub.dto.*;
import br.com.hqhub.entity.*;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.repository.*;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class OrdemLeituraService {
    private final OrdemLeituraRepository ordens;
    private final ItemOrdemLeituraRepository itens;
    private final ProgressoOrdemLeituraRepository progressos;
    private final ItemColecaoRepository itensColecao;
    private final UsuarioAutenticadoService usuarioAutenticado;

    public OrdemLeituraService(OrdemLeituraRepository ordens, ItemOrdemLeituraRepository itens,
            ProgressoOrdemLeituraRepository progressos, ItemColecaoRepository itensColecao,
            UsuarioAutenticadoService usuarioAutenticado) {
        this.ordens = ordens; this.itens = itens; this.progressos = progressos;
        this.itensColecao = itensColecao;
        this.usuarioAutenticado = usuarioAutenticado;
    }

    @Transactional
    public List<OrdemLeituraResumoDTO> listar() {
        Usuario usuario = usuarioAutenticado.obterUsuario();
        return ordens.list("publicada = true order by titulo").stream().map(ordem -> {
            long total = itens.count("ordemLeitura.id", ordem.getId());
            long lidos = progressos.count("usuario.id = ?1 and item.ordemLeitura.id = ?2 and lido = true",
                    usuario.getId(), ordem.getId());
            return new OrdemLeituraResumoDTO(ordem.getId(), ordem.getSlug(), ordem.getTitulo(),
                    ordem.getDescricao(), ordem.getUrlCapa(), total, lidos);
        }).toList();
    }

    @Transactional
    public OrdemLeituraDetalheDTO buscar(String slug) {
        Usuario usuario = usuarioAutenticado.obterUsuario();
        OrdemLeitura ordem = ordens.find("slug = ?1 and publicada = true", slug).firstResultOptional()
                .orElseThrow(() -> new RecursoNaoEncontradoException("Ordem de leitura nao encontrada."));
        Set<Long> lidos = new HashSet<>();
        progressos.listar(usuario.getId(), ordem.getId()).stream().filter(ProgressoOrdemLeitura::isLido)
                .forEach(p -> lidos.add(p.getItem().getId()));
        List<ItemOrdemLeitura> itensOrdem = itens.listar(ordem.getId());
        Set<Long> edicoesIds = itensOrdem.stream().map(ItemOrdemLeitura::getEdicao).filter(Objects::nonNull)
                .map(Edicao::getId).collect(java.util.stream.Collectors.toSet());
        Map<Long, Long> itensColecaoPorEdicao = new HashMap<>();
        itensColecao.listarPorUsuarioEEdicoes(usuario.getId(), edicoesIds)
                .forEach(item -> itensColecaoPorEdicao.put(item.getEdicao().getId(), item.getId()));
        List<ItemOrdemLeituraDTO> resposta = itensOrdem.stream()
                .map(item -> paraDto(item, lidos, itensColecaoPorEdicao)).toList();
        return new OrdemLeituraDetalheDTO(ordem.getId(), ordem.getSlug(), ordem.getTitulo(), ordem.getDescricao(),
                resposta.size(), lidos.size(), resposta);
    }

    @Transactional
    public ItemOrdemLeituraDTO atualizarProgresso(Long itemId, boolean lido) {
        Usuario usuario = usuarioAutenticado.obterUsuario();
        ItemOrdemLeitura item = itens.findByIdOptional(itemId)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Item da ordem de leitura nao encontrado."));
        ProgressoOrdemLeitura progresso = progressos
                .find("usuario.id = ?1 and item.id = ?2", usuario.getId(), itemId).firstResult();
        if (progresso == null) {
            progresso = new ProgressoOrdemLeitura(); progresso.setUsuario(usuario); progresso.setItem(item);
            progressos.persist(progresso);
        }
        progresso.setLido(lido); progresso.setDataAtualizacao(LocalDateTime.now());
        Long itemColecaoId = item.getEdicao() == null ? null : itensColecao
                .find("usuario.id = ?1 and edicao.id = ?2", usuario.getId(), item.getEdicao().getId())
                .firstResultOptional().map(ItemColecao::getId).orElse(null);
        return paraDto(item, lido ? Set.of(itemId) : Set.of(),
                item.getEdicao() == null || itemColecaoId == null ? Map.of() : Map.of(item.getEdicao().getId(), itemColecaoId));
    }

    private ItemOrdemLeituraDTO paraDto(ItemOrdemLeitura item, Set<Long> lidos, Map<Long, Long> itensColecaoPorEdicao) {
        Edicao edicao = item.getEdicao();
        String titulo = edicao == null ? item.getTituloReferencia()
                : edicao.getSerie().getTitulo() + " #" + edicao.getNumero();
        String capa = edicao != null && edicao.getUrlCapa() != null ? edicao.getUrlCapa() : item.getUrlCapaReferencia();
        Long itemColecaoId = edicao == null ? null : itensColecaoPorEdicao.get(edicao.getId());
        return new ItemOrdemLeituraDTO(item.getId(), item.getPosicao(), item.getSecao(), edicao == null ? null : edicao.getId(),
                edicao == null ? null : edicao.getSerie().getId(), titulo, item.getDetalheReferencia(), capa,
                lidos.contains(item.getId()), edicao != null, itemColecaoId != null, itemColecaoId, item.getStatusIdentificacao(),
                item.getObservacao(), item.getAnoReferencia());
    }
}
