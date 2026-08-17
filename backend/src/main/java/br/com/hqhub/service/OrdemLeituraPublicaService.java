package br.com.hqhub.service;

import java.util.List;

import br.com.hqhub.dto.ItemOrdemLeituraDTO;
import br.com.hqhub.dto.OrdemLeituraDetalheDTO;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.ItemOrdemLeitura;
import br.com.hqhub.entity.OrdemLeitura;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.repository.ItemOrdemLeituraRepository;
import br.com.hqhub.repository.OrdemLeituraRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class OrdemLeituraPublicaService {
    private final OrdemLeituraRepository ordens;
    private final ItemOrdemLeituraRepository itens;

    public OrdemLeituraPublicaService(OrdemLeituraRepository ordens, ItemOrdemLeituraRepository itens) {
        this.ordens = ordens;
        this.itens = itens;
    }

    @Transactional
    public OrdemLeituraDetalheDTO buscarPublica(String slug) {
        OrdemLeitura ordem = ordens.find("slug = ?1 and publicada = true", slug).firstResultOptional()
                .orElseThrow(() -> new RecursoNaoEncontradoException("Ordem de leitura nao encontrada."));
        List<ItemOrdemLeituraDTO> resposta = itens.listar(ordem.getId()).stream()
                .map(this::paraDto)
                .toList();
        return new OrdemLeituraDetalheDTO(ordem.getId(), ordem.getSlug(), ordem.getTitulo(), ordem.getDescricao(),
                resposta.size(), 0, resposta);
    }

    private ItemOrdemLeituraDTO paraDto(ItemOrdemLeitura item) {
        Edicao edicao = item.getEdicao();
        String titulo = edicao == null ? item.getTituloReferencia()
                : edicao.getSerie().getTitulo() + " #" + edicao.getNumero();
        String capa = edicao != null && edicao.getUrlCapa() != null ? edicao.getUrlCapa() : item.getUrlCapaReferencia();
        return new ItemOrdemLeituraDTO(item.getId(), item.getPosicao(), item.getSecao(), edicao == null ? null : edicao.getId(),
                edicao == null ? null : edicao.getSerie().getId(), titulo, item.getDetalheReferencia(), capa,
                false, edicao != null);
    }
}
