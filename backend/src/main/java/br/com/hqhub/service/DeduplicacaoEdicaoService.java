package br.com.hqhub.service;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.function.Consumer;
import java.util.function.Supplier;
import java.util.stream.Collectors;

import br.com.hqhub.dto.EdicaoRespostaDTO;
import br.com.hqhub.dto.GrupoDuplicidadeEdicaoDTO;
import br.com.hqhub.dto.ResultadoDeduplicacaoEdicoesDTO;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.mapper.EdicaoMapper;
import br.com.hqhub.repository.EdicaoRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.persistence.EntityManager;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class DeduplicacaoEdicaoService {

    private final EdicaoRepository edicaoRepository;
    private final EdicaoMapper edicaoMapper;
    private final EntityManager entityManager;

    public DeduplicacaoEdicaoService(
            EdicaoRepository edicaoRepository,
            EdicaoMapper edicaoMapper,
            EntityManager entityManager) {
        this.edicaoRepository = edicaoRepository;
        this.edicaoMapper = edicaoMapper;
        this.entityManager = entityManager;
    }

    @Transactional
    public List<GrupoDuplicidadeEdicaoDTO> listarDuplicidades() {
        return montarGruposDuplicados().stream()
                .map(grupo -> montarResumoGrupo(grupo, true))
                .toList();
    }

    @Transactional
    public ResultadoDeduplicacaoEdicoesDTO deduplicar() {
        List<List<Edicao>> grupos = montarGruposDuplicados();
        List<GrupoDuplicidadeEdicaoDTO> gruposMesclados = new ArrayList<>();
        int edicoesRemovidas = 0;
        int referenciasAtualizadas = 0;

        for (List<Edicao> grupo : grupos) {
            Edicao mantida = escolherMaisCompleta(grupo);
            List<Edicao> descartadas = grupo.stream()
                    .filter(edicao -> !Objects.equals(edicao.getId(), mantida.getId()))
                    .sorted(Comparator.comparing(Edicao::getId))
                    .toList();

            for (Edicao descartada : descartadas) {
                copiarCamposFaltantes(mantida, descartada);
                referenciasAtualizadas += moverReferencias(descartada.getId(), mantida.getId());
                entityManager.remove(entityManager.contains(descartada) ? descartada : entityManager.merge(descartada));
                edicoesRemovidas++;
            }

            gruposMesclados.add(montarResumoGrupo(mantida, descartadas));
        }

        entityManager.flush();

        return new ResultadoDeduplicacaoEdicoesDTO(
                grupos.size(),
                gruposMesclados.size(),
                edicoesRemovidas,
                referenciasAtualizadas,
                gruposMesclados);
    }

    private List<List<Edicao>> montarGruposDuplicados() {
        Map<String, List<Edicao>> candidatos = edicaoRepository.listAll().stream()
                .collect(Collectors.groupingBy(this::chaveAmpla, LinkedHashMap::new, Collectors.toList()));

        return candidatos.values().stream()
                .filter(grupo -> grupo.size() > 1)
                .flatMap(grupo -> separarPorCompatibilidade(grupo).stream())
                .filter(grupo -> grupo.size() > 1)
                .toList();
    }

    private List<List<Edicao>> separarPorCompatibilidade(List<Edicao> candidatas) {
        List<List<Edicao>> grupos = new ArrayList<>();

        for (Edicao edicao : candidatas.stream().sorted(Comparator.comparing(Edicao::getId)).toList()) {
            List<Edicao> compativel = grupos.stream()
                    .filter(grupo -> grupo.stream().allMatch(existente -> podeMesclar(existente, edicao)))
                    .findFirst()
                    .orElse(null);

            if (compativel == null) {
                compativel = new ArrayList<>();
                grupos.add(compativel);
            }

            compativel.add(edicao);
        }

        return grupos;
    }

    private boolean podeMesclar(Edicao primeira, Edicao segunda) {
        return mesmoValorOuAlgumVazio(primeira.getTitulo(), segunda.getTitulo())
                && mesmoValorOuAlgumNulo(primeira.getSerie().getVolume(), segunda.getSerie().getVolume())
                && mesmaOrigemOuAlgumaVazia(primeira, segunda);
    }

    private boolean mesmaOrigemOuAlgumaVazia(Edicao primeira, Edicao segunda) {
        if (vazio(primeira.getFonteExterna()) || vazio(primeira.getIdExterno())
                || vazio(segunda.getFonteExterna()) || vazio(segunda.getIdExterno())) {
            return true;
        }

        return primeira.getFonteExterna().equalsIgnoreCase(segunda.getFonteExterna())
                && primeira.getIdExterno().equalsIgnoreCase(segunda.getIdExterno());
    }

    private GrupoDuplicidadeEdicaoDTO montarResumoGrupo(List<Edicao> grupo, boolean ordenarDescartadas) {
        Edicao mantida = escolherMaisCompleta(grupo);
        List<EdicaoRespostaDTO> descartadas = grupo.stream()
                .filter(edicao -> !Objects.equals(edicao.getId(), mantida.getId()))
                .sorted(ordenarDescartadas ? Comparator.comparing(Edicao::getId) : Comparator.comparing(this::pontuar).reversed())
                .map(edicaoMapper::paraResposta)
                .toList();

        return new GrupoDuplicidadeEdicaoDTO(
                chaveAmpla(mantida),
                edicaoMapper.paraResposta(mantida),
                descartadas,
                pontuar(mantida));
    }

    private GrupoDuplicidadeEdicaoDTO montarResumoGrupo(Edicao mantida, List<Edicao> descartadas) {
        return new GrupoDuplicidadeEdicaoDTO(
                chaveAmpla(mantida),
                edicaoMapper.paraResposta(mantida),
                descartadas.stream()
                        .sorted(Comparator.comparing(Edicao::getId))
                        .map(edicaoMapper::paraResposta)
                        .toList(),
                pontuar(mantida));
    }

    private Edicao escolherMaisCompleta(List<Edicao> grupo) {
        return grupo.stream()
                .max(Comparator.comparingInt(this::pontuar).thenComparing(Edicao::getId, Comparator.reverseOrder()))
                .orElseThrow();
    }

    private int pontuar(Edicao edicao) {
        int pontos = 0;
        pontos += pontosTexto(edicao.getTitulo(), 2);
        pontos += pontosTexto(edicao.getDescricao(), 2);
        pontos += pontosTexto(edicao.getDescricaoOriginal(), 2);
        pontos += pontosTexto(edicao.getDescricaoPortugues(), 3);
        pontos += pontosTexto(edicao.getNomeVolume(), 1);
        pontos += pontosTexto(edicao.getUrlCapa(), 5);
        pontos += pontosTexto(edicao.getCodigoBarras(), 2);
        pontos += pontosTexto(edicao.getFormato(), 2);
        pontos += pontosTexto(edicao.getFonteExterna(), 2);
        pontos += pontosTexto(edicao.getIdExterno(), 2);
        pontos += pontosTexto(edicao.getUrlOrigem(), 2);
        pontos += pontosTexto(edicao.getUrlComicVine(), 2);
        pontos += pontosTexto(edicao.getIdComicVine(), 2);
        pontos += edicao.getDataPublicacao() == null ? 0 : 2;
        pontos += edicao.getDataCobertura() == null ? 0 : 1;
        pontos += edicao.getDataDisponibilidadeLoja() == null ? 0 : 1;
        pontos += edicao.getQuantidadePaginas() == null ? 0 : 1;
        pontos += edicao.getPrecoCapa() == null ? 0 : 1;
        pontos += contarReferencias("itens_colecao", "edicao_id", edicao.getId());
        pontos += contarReferencias("conteudos_edicoes", "edicao_id", edicao.getId());
        pontos += contarReferencias("creditos_edicoes", "edicao_id", edicao.getId());
        pontos += contarReferencias("links_edicoes", "edicao_id", edicao.getId());
        return pontos;
    }

    private int pontosTexto(String valor, int pontos) {
        return vazio(valor) ? 0 : pontos;
    }

    private int contarReferencias(String tabela, String coluna, Long edicaoId) {
        Number total = (Number) entityManager
                .createNativeQuery("select count(*) from " + tabela + " where " + coluna + " = :edicaoId")
                .setParameter("edicaoId", edicaoId)
                .getSingleResult();
        return total.intValue();
    }

    private void copiarCamposFaltantes(Edicao mantida, Edicao descartada) {
        copiarSeVazio(mantida::getTitulo, mantida::setTitulo, descartada.getTitulo());
        copiarSeVazio(mantida::getDescricao, mantida::setDescricao, descartada.getDescricao());
        copiarSeVazio(mantida::getDescricaoOriginal, mantida::setDescricaoOriginal, descartada.getDescricaoOriginal());
        copiarSeVazio(mantida::getDescricaoPortugues, mantida::setDescricaoPortugues, descartada.getDescricaoPortugues());
        copiarSeVazio(mantida::getNomeVolume, mantida::setNomeVolume, descartada.getNomeVolume());
        copiarSeNulo(mantida::getDataCobertura, mantida::setDataCobertura, descartada.getDataCobertura());
        copiarSeNulo(mantida::getDataDisponibilidadeLoja, mantida::setDataDisponibilidadeLoja, descartada.getDataDisponibilidadeLoja());
        copiarSeNulo(mantida::getDataPublicacao, mantida::setDataPublicacao, descartada.getDataPublicacao());
        copiarSeVazio(mantida::getUrlCapa, mantida::setUrlCapa, descartada.getUrlCapa());
        copiarSeVazio(mantida::getCodigoBarras, mantida::setCodigoBarras, descartada.getCodigoBarras());
        copiarSeNulo(mantida::getQuantidadePaginas, mantida::setQuantidadePaginas, descartada.getQuantidadePaginas());
        copiarSeNulo(mantida::getPrecoCapa, mantida::setPrecoCapa, descartada.getPrecoCapa());
        copiarSeVazio(mantida::getFormato, mantida::setFormato, descartada.getFormato());
        copiarOrigemSeFaltante(mantida, descartada);
        copiarSeVazio(mantida::getUrlOrigem, mantida::setUrlOrigem, descartada.getUrlOrigem());
        copiarSeVazio(mantida::getUrlComicVine, mantida::setUrlComicVine, descartada.getUrlComicVine());
        copiarSeVazio(mantida::getIdComicVine, mantida::setIdComicVine, descartada.getIdComicVine());
    }

    private void copiarOrigemSeFaltante(Edicao mantida, Edicao descartada) {
        if ((vazio(mantida.getFonteExterna()) || vazio(mantida.getIdExterno()))
                && !vazio(descartada.getFonteExterna()) && !vazio(descartada.getIdExterno())) {
            mantida.setFonteExterna(descartada.getFonteExterna());
            mantida.setIdExterno(descartada.getIdExterno());
        }
    }

    private <T> void copiarSeNulo(Supplier<T> atual, Consumer<T> atualizar, T novoValor) {
        if (atual.get() == null && novoValor != null) {
            atualizar.accept(novoValor);
        }
    }

    private void copiarSeVazio(Supplier<String> atual, Consumer<String> atualizar, String novoValor) {
        if (vazio(atual.get()) && !vazio(novoValor)) {
            atualizar.accept(novoValor);
        }
    }

    private int moverReferencias(Long descartadaId, Long mantidaId) {
        int alteradas = 0;

        alteradas += executar("""
                update anuncios anuncio
                   set item_colecao_id = item_mantido.id
                  from itens_colecao item_descartado
                  join itens_colecao item_mantido
                    on item_mantido.usuario_id = item_descartado.usuario_id
                   and item_mantido.edicao_id = :mantida
                 where anuncio.item_colecao_id = item_descartado.id
                   and item_descartado.edicao_id = :descartada
                """, descartadaId, mantidaId);
        alteradas += executar("""
                delete from itens_colecao item_descartado
                 using itens_colecao item_mantido
                 where item_descartado.edicao_id = :descartada
                   and item_mantido.edicao_id = :mantida
                   and item_descartado.usuario_id = item_mantido.usuario_id
                """, descartadaId, mantidaId);
        alteradas += executar("update itens_colecao set edicao_id = :mantida where edicao_id = :descartada", descartadaId, mantidaId);

        alteradas += executar("""
                delete from compras_planejadas descartada
                 using compras_planejadas mantida
                 where descartada.edicao_id = :descartada
                   and mantida.edicao_id = :mantida
                   and descartada.usuario_id = mantida.usuario_id
                   and descartada.mes = mantida.mes
                   and descartada.ano = mantida.ano
                """, descartadaId, mantidaId);
        alteradas += executar("update compras_planejadas set edicao_id = :mantida where edicao_id = :descartada", descartadaId, mantidaId);

        alteradas += executar("""
                delete from creditos_edicoes descartada
                 using creditos_edicoes mantida
                 where descartada.edicao_id = :descartada
                   and mantida.edicao_id = :mantida
                   and descartada.criador_id = mantida.criador_id
                   and descartada.papel = mantida.papel
                """, descartadaId, mantidaId);
        alteradas += executar("update creditos_edicoes set edicao_id = :mantida where edicao_id = :descartada", descartadaId, mantidaId);

        alteradas += executar("""
                delete from links_edicoes descartada
                 using links_edicoes mantida
                 where descartada.edicao_id = :descartada
                   and mantida.edicao_id = :mantida
                   and descartada.url = mantida.url
                """, descartadaId, mantidaId);
        alteradas += executar("update links_edicoes set edicao_id = :mantida where edicao_id = :descartada", descartadaId, mantidaId);

        alteradas += executar("""
                delete from conteudos_edicoes descartada
                 using conteudos_edicoes mantida
                 where descartada.edicao_id = :descartada
                   and mantida.edicao_id = :mantida
                   and descartada.ordem = mantida.ordem
                """, descartadaId, mantidaId);
        alteradas += executar("update conteudos_edicoes set edicao_id = :mantida where edicao_id = :descartada", descartadaId, mantidaId);

        alteradas += executar("""
                delete from publicacoes_historias
                 where (edicao_original_id = :descartada and edicao_publicada_id = :mantida)
                    or (edicao_original_id = :mantida and edicao_publicada_id = :descartada)
                """, descartadaId, mantidaId);
        alteradas += executar("""
                delete from publicacoes_historias descartada
                 using publicacoes_historias mantida
                 where descartada.edicao_publicada_id = :descartada
                   and mantida.edicao_publicada_id = :mantida
                   and descartada.historia_id = mantida.historia_id
                """, descartadaId, mantidaId);
        alteradas += executar("update publicacoes_historias set edicao_original_id = :mantida where edicao_original_id = :descartada", descartadaId, mantidaId);
        alteradas += executar("update publicacoes_historias set edicao_publicada_id = :mantida where edicao_publicada_id = :descartada", descartadaId, mantidaId);

        alteradas += executar("""
                delete from publicacoes_relacionadas
                 where (edicao_origem_id = :descartada and edicao_destino_id = :mantida)
                    or (edicao_origem_id = :mantida and edicao_destino_id = :descartada)
                """, descartadaId, mantidaId);
        alteradas += executar("""
                delete from publicacoes_relacionadas descartada
                 using publicacoes_relacionadas mantida
                 where descartada.edicao_origem_id = :descartada
                   and mantida.edicao_origem_id = :mantida
                   and descartada.edicao_destino_id = mantida.edicao_destino_id
                   and descartada.tipo = mantida.tipo
                """, descartadaId, mantidaId);
        alteradas += executar("update publicacoes_relacionadas set edicao_origem_id = :mantida where edicao_origem_id = :descartada", descartadaId, mantidaId);
        alteradas += executar("""
                delete from publicacoes_relacionadas descartada
                 using publicacoes_relacionadas mantida
                 where descartada.edicao_destino_id = :descartada
                   and mantida.edicao_destino_id = :mantida
                   and descartada.edicao_origem_id = mantida.edicao_origem_id
                   and descartada.tipo = mantida.tipo
                """, descartadaId, mantidaId);
        alteradas += executar("update publicacoes_relacionadas set edicao_destino_id = :mantida where edicao_destino_id = :descartada", descartadaId, mantidaId);

        alteradas += executar("update contribuicoes_catalogo set edicao_id = :mantida where edicao_id = :descartada", descartadaId, mantidaId);
        alteradas += executar("update contribuicoes_catalogo set edicao_destino_id = :mantida where edicao_destino_id = :descartada", descartadaId, mantidaId);

        return alteradas;
    }

    private int executar(String sql, Long descartadaId, Long mantidaId) {
        return entityManager.createNativeQuery(sql)
                .setParameter("descartada", descartadaId)
                .setParameter("mantida", mantidaId)
                .executeUpdate();
    }

    private String chaveAmpla(Edicao edicao) {
        return normalizar(edicao.getSerie().getEditora().getNome()) + "|"
                + normalizar(edicao.getSerie().getTitulo()) + "|"
                + normalizar(edicao.getNumero());
    }

    private boolean mesmoValorOuAlgumVazio(String primeiro, String segundo) {
        return vazio(primeiro) || vazio(segundo) || normalizar(primeiro).equals(normalizar(segundo));
    }

    private boolean mesmoValorOuAlgumNulo(Integer primeiro, Integer segundo) {
        return primeiro == null || segundo == null || primeiro.equals(segundo);
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

    private boolean vazio(String valor) {
        return valor == null || valor.isBlank();
    }
}
