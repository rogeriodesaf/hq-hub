package br.com.hqhub.service;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

import br.com.hqhub.dto.GrupoDuplicidadeSerieDTO;
import br.com.hqhub.dto.ResultadoDeduplicacaoSeriesDTO;
import br.com.hqhub.dto.SerieRespostaDTO;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.Serie;
import br.com.hqhub.mapper.SerieMapper;
import br.com.hqhub.repository.SerieRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.persistence.EntityManager;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class DeduplicacaoSerieService {

    private static final Set<String> ARTIGOS = Set.of("a", "as", "o", "os");

    private final SerieRepository serieRepository;
    private final SerieMapper serieMapper;
    private final DeduplicacaoEdicaoService deduplicacaoEdicaoService;
    private final EntityManager entityManager;

    public DeduplicacaoSerieService(
            SerieRepository serieRepository,
            SerieMapper serieMapper,
            DeduplicacaoEdicaoService deduplicacaoEdicaoService,
            EntityManager entityManager) {
        this.serieRepository = serieRepository;
        this.serieMapper = serieMapper;
        this.deduplicacaoEdicaoService = deduplicacaoEdicaoService;
        this.entityManager = entityManager;
    }

    @Transactional
    public List<GrupoDuplicidadeSerieDTO> listarDuplicidades() {
        return montarGruposDuplicados().stream()
                .map(grupo -> montarResumoGrupo(grupo, true))
                .toList();
    }

    @Transactional
    public ResultadoDeduplicacaoSeriesDTO deduplicar() {
        List<List<Serie>> grupos = montarGruposDuplicados();
        List<GrupoDuplicidadeSerieDTO> gruposMesclados = new ArrayList<>();
        int seriesRemovidas = 0;
        int edicoesMescladas = 0;
        int referenciasAtualizadas = 0;

        for (List<Serie> grupo : grupos) {
            Serie mantida = escolherMaisCompleta(grupo);
            List<Serie> descartadas = grupo.stream()
                    .filter(serie -> !Objects.equals(serie.getId(), mantida.getId()))
                    .sorted(Comparator.comparing(Serie::getId))
                    .toList();

            for (Serie descartada : descartadas) {
                copiarCamposFaltantes(mantida, descartada);
                ResultadoMesclagemSerie resultado = mesclarSerie(descartada, mantida);
                edicoesMescladas += resultado.edicoesMescladas();
                referenciasAtualizadas += resultado.referenciasAtualizadas();
                seriesRemovidas++;
            }

            gruposMesclados.add(montarResumoGrupo(mantida, descartadas));
        }

        entityManager.flush();

        return new ResultadoDeduplicacaoSeriesDTO(
                grupos.size(),
                gruposMesclados.size(),
                seriesRemovidas,
                edicoesMescladas,
                referenciasAtualizadas,
                gruposMesclados);
    }

    private List<List<Serie>> montarGruposDuplicados() {
        Map<String, List<Serie>> candidatos = serieRepository.listAll().stream()
                .collect(Collectors.groupingBy(this::chaveAmpla, LinkedHashMap::new, Collectors.toList()));

        return candidatos.values().stream()
                .filter(grupo -> grupo.size() > 1)
                .flatMap(grupo -> separarPorCompatibilidade(grupo).stream())
                .filter(grupo -> grupo.size() > 1)
                .toList();
    }

    private List<List<Serie>> separarPorCompatibilidade(List<Serie> candidatas) {
        List<List<Serie>> grupos = new ArrayList<>();

        for (Serie serie : candidatas.stream().sorted(Comparator.comparing(Serie::getId)).toList()) {
            List<Serie> compativel = grupos.stream()
                    .filter(grupo -> grupo.stream().allMatch(existente -> podeMesclar(existente, serie)))
                    .findFirst()
                    .orElse(null);

            if (compativel == null) {
                compativel = new ArrayList<>();
                grupos.add(compativel);
            }

            compativel.add(serie);
        }

        return grupos;
    }

    private boolean podeMesclar(Serie primeira, Serie segunda) {
        return Objects.equals(primeira.getEditora().getId(), segunda.getEditora().getId())
                && mesmoValorOuAlgumNulo(primeira.getVolume(), segunda.getVolume())
                && mesmoValorOuAlgumNulo(primeira.getAnoInicio(), segunda.getAnoInicio())
                && mesmaOrigemOuAlgumaVazia(primeira, segunda);
    }

    private ResultadoMesclagemSerie mesclarSerie(Serie descartada, Serie mantida) {
        int edicoesMescladas = 0;
        int referenciasAtualizadas = 0;

        for (Edicao edicaoDescartada : listarEdicoes(descartada.getId())) {
            Edicao edicaoMantida = buscarEdicaoPorNumero(mantida.getId(), edicaoDescartada.getNumero());
            if (edicaoMantida == null) {
                edicaoDescartada.setSerie(mantida);
                referenciasAtualizadas++;
            } else {
                referenciasAtualizadas += deduplicacaoEdicaoService.mesclarEdicoes(edicaoDescartada.getId(), edicaoMantida.getId());
                edicoesMescladas++;
            }
        }

        moverColecoesSeries(descartada.getId(), mantida.getId());
        moverRelacionamentosSeries(descartada.getId(), mantida.getId());
        entityManager.remove(entityManager.contains(descartada) ? descartada : entityManager.merge(descartada));
        return new ResultadoMesclagemSerie(edicoesMescladas, referenciasAtualizadas);
    }

    private List<Edicao> listarEdicoes(Long serieId) {
        return entityManager.createQuery("from Edicao where serie.id = :serieId order by id", Edicao.class)
                .setParameter("serieId", serieId)
                .getResultList();
    }

    private Edicao buscarEdicaoPorNumero(Long serieId, String numero) {
        return entityManager.createQuery("""
                from Edicao
                where serie.id = :serieId
                  and lower(numero) = :numero
                """, Edicao.class)
                .setParameter("serieId", serieId)
                .setParameter("numero", numero == null ? "" : numero.toLowerCase(Locale.ROOT))
                .setMaxResults(1)
                .getResultStream()
                .findFirst()
                .orElse(null);
    }

    private void moverColecoesSeries(Long descartadaId, Long mantidaId) {
        executar("""
                delete from colecoes_series descartada
                 using colecoes_series mantida
                 where descartada.serie_id = :descartada
                   and mantida.serie_id = :mantida
                   and descartada.usuario_id = mantida.usuario_id
                """, descartadaId, mantidaId);
        executar("update colecoes_series set serie_id = :mantida where serie_id = :descartada", descartadaId, mantidaId);
    }

    private void moverRelacionamentosSeries(Long descartadaId, Long mantidaId) {
        executar("delete from relacionamentos_series where serie_origem_id = :descartada and serie_destino_id = :mantida", descartadaId, mantidaId);
        executar("delete from relacionamentos_series where serie_origem_id = :mantida and serie_destino_id = :descartada", descartadaId, mantidaId);
        executar("update relacionamentos_series set serie_origem_id = :mantida where serie_origem_id = :descartada", descartadaId, mantidaId);
        executar("update relacionamentos_series set serie_destino_id = :mantida where serie_destino_id = :descartada", descartadaId, mantidaId);
        executarSemParametros("""
                delete from relacionamentos_series duplicado
                 using relacionamentos_series mantido
                 where duplicado.id > mantido.id
                   and duplicado.serie_origem_id = mantido.serie_origem_id
                   and duplicado.serie_destino_id = mantido.serie_destino_id
                   and duplicado.tipo = mantido.tipo
                """);
    }

    private int executar(String sql, Long descartadaId, Long mantidaId) {
        return entityManager.createNativeQuery(sql)
                .setParameter("descartada", descartadaId)
                .setParameter("mantida", mantidaId)
                .executeUpdate();
    }

    private int executarSemParametros(String sql) {
        return entityManager.createNativeQuery(sql).executeUpdate();
    }

    private GrupoDuplicidadeSerieDTO montarResumoGrupo(List<Serie> grupo, boolean ordenarDescartadas) {
        Serie mantida = escolherMaisCompleta(grupo);
        List<SerieRespostaDTO> descartadas = grupo.stream()
                .filter(serie -> !Objects.equals(serie.getId(), mantida.getId()))
                .sorted(ordenarDescartadas ? Comparator.comparing(Serie::getId) : Comparator.comparing(this::pontuar).reversed())
                .map(serieMapper::paraResposta)
                .toList();

        return new GrupoDuplicidadeSerieDTO(chaveAmpla(mantida), serieMapper.paraResposta(mantida), descartadas, pontuar(mantida));
    }

    private GrupoDuplicidadeSerieDTO montarResumoGrupo(Serie mantida, List<Serie> descartadas) {
        return new GrupoDuplicidadeSerieDTO(
                chaveAmpla(mantida),
                serieMapper.paraResposta(mantida),
                descartadas.stream().map(serieMapper::paraResposta).toList(),
                pontuar(mantida));
    }

    private Serie escolherMaisCompleta(List<Serie> grupo) {
        return grupo.stream()
                .max(Comparator.comparingInt(this::pontuar).thenComparing(Serie::getId, Comparator.reverseOrder()))
                .orElseThrow();
    }

    private int pontuar(Serie serie) {
        int pontos = 0;
        pontos += vazio(serie.getDescricao()) ? 0 : 2;
        pontos += serie.getAnoInicio() == null ? 0 : 2;
        pontos += serie.getAnoFim() == null ? 0 : 1;
        pontos += serie.getVolume() == null ? 0 : 1;
        pontos += serie.getOrdemCronologica() == null ? 0 : 1;
        pontos += vazio(serie.getFonteExterna()) ? 0 : 2;
        pontos += vazio(serie.getIdExterno()) ? 0 : 2;
        pontos += vazio(serie.getUrlOrigem()) ? 0 : 1;
        pontos += listarEdicoes(serie.getId()).size() * 3;
        return pontos;
    }

    private void copiarCamposFaltantes(Serie mantida, Serie descartada) {
        if (vazio(mantida.getDescricao()) && !vazio(descartada.getDescricao())) {
            mantida.setDescricao(descartada.getDescricao());
        }
        if (mantida.getAnoInicio() == null) {
            mantida.setAnoInicio(descartada.getAnoInicio());
        }
        if (mantida.getAnoFim() == null) {
            mantida.setAnoFim(descartada.getAnoFim());
        }
        if (mantida.getVolume() == null) {
            mantida.setVolume(descartada.getVolume());
        }
        if (mantida.getOrdemCronologica() == null) {
            mantida.setOrdemCronologica(descartada.getOrdemCronologica());
        }
        if ((vazio(mantida.getFonteExterna()) || vazio(mantida.getIdExterno()))
                && !vazio(descartada.getFonteExterna()) && !vazio(descartada.getIdExterno())) {
            mantida.setFonteExterna(descartada.getFonteExterna());
            mantida.setIdExterno(descartada.getIdExterno());
        }
        if (vazio(mantida.getUrlOrigem()) && !vazio(descartada.getUrlOrigem())) {
            mantida.setUrlOrigem(descartada.getUrlOrigem());
        }
    }

    private String chaveAmpla(Serie serie) {
        return serie.getEditora().getId() + "|" + normalizarTitulo(serie.getTitulo()) + "|" + (serie.getVolume() == null ? 0 : serie.getVolume());
    }

    private boolean mesmoValorOuAlgumNulo(Integer primeiro, Integer segundo) {
        return primeiro == null || segundo == null || primeiro.equals(segundo);
    }

    private boolean mesmaOrigemOuAlgumaVazia(Serie primeira, Serie segunda) {
        if (vazio(primeira.getFonteExterna()) || vazio(primeira.getIdExterno())
                || vazio(segunda.getFonteExterna()) || vazio(segunda.getIdExterno())) {
            return true;
        }

        return primeira.getFonteExterna().equalsIgnoreCase(segunda.getFonteExterna())
                && primeira.getIdExterno().equalsIgnoreCase(segunda.getIdExterno());
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

    private record ResultadoMesclagemSerie(int edicoesMescladas, int referenciasAtualizadas) {
    }
}
