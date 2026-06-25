package br.com.hqhub.service;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import br.com.hqhub.dto.ResultadoNormalizacaoTextoDTO;
import br.com.hqhub.util.NormalizadorTexto;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.persistence.EntityManager;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class NormalizacaoTextoService {

    private final EntityManager entityManager;

    public NormalizacaoTextoService(EntityManager entityManager) {
        this.entityManager = entityManager;
    }

    @Transactional
    public ResultadoNormalizacaoTextoDTO normalizarCatalogo() {
        Map<String, Integer> camposPorTabela = new LinkedHashMap<>();

        List<TabelaTexto> tabelas = List.of(
                new TabelaTexto("editoras", List.of("nome", "descricao", "pais_origem")),
                new TabelaTexto("series", List.of("titulo", "descricao")),
                new TabelaTexto("edicoes", List.of(
                        "numero",
                        "titulo",
                        "descricao",
                        "nome_volume",
                        "descricao_original",
                        "descricao_portugues",
                        "formato")),
                new TabelaTexto("historias", List.of(
                        "titulo",
                        "titulo_original",
                        "titulo_portugues",
                        "descricao",
                        "descricao_original",
                        "descricao_portugues")),
                new TabelaTexto("conteudos_edicoes", List.of("titulo_usado", "observacoes")),
                new TabelaTexto("publicacoes_historias", List.of("fonte_informacao", "titulo_usado", "observacoes")),
                new TabelaTexto("publicacoes_relacionadas", List.of("fonte_externa", "observacoes")),
                new TabelaTexto("criadores", List.of("nome", "nome_artistico")),
                new TabelaTexto("creditos_edicoes", List.of("observacoes")),
                new TabelaTexto("links_edicoes", List.of("titulo", "observacoes")));

        int camposCorrigidos = 0;
        for (TabelaTexto tabela : tabelas) {
            int corrigidosTabela = 0;
            for (String coluna : tabela.colunas()) {
                corrigidosTabela += normalizarColuna(tabela.nome(), coluna);
            }
            if (corrigidosTabela > 0) {
                camposPorTabela.put(tabela.nome(), corrigidosTabela);
                camposCorrigidos += corrigidosTabela;
            }
        }

        int registrosAfetados = camposPorTabela.values().stream().mapToInt(Integer::intValue).sum();
        return new ResultadoNormalizacaoTextoDTO(registrosAfetados, camposCorrigidos, camposPorTabela);
    }

    private int normalizarColuna(String tabela, String coluna) {
        @SuppressWarnings("unchecked")
        List<Object[]> linhas = entityManager
                .createNativeQuery("select id, " + coluna + " from " + tabela + " where " + coluna + " is not null")
                .getResultList();

        int corrigidos = 0;
        for (Object[] linha : linhas) {
            Number id = (Number) linha[0];
            String valor = (String) linha[1];
            String normalizado = NormalizadorTexto.corrigirMojibake(valor);
            if (normalizado != null && !normalizado.equals(valor)) {
                entityManager
                        .createNativeQuery("update " + tabela + " set " + coluna + " = :valor where id = :id")
                        .setParameter("valor", normalizado)
                        .setParameter("id", id.longValue())
                        .executeUpdate();
                corrigidos++;
            }
        }
        return corrigidos;
    }

    private record TabelaTexto(String nome, List<String> colunas) {
    }
}
