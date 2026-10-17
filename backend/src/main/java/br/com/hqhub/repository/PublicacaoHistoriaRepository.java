package br.com.hqhub.repository;

import java.util.List;
import java.util.Optional;
import java.time.LocalDate;

import br.com.hqhub.entity.PublicacaoHistoria;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.persistence.EntityManager;

@ApplicationScoped
public class PublicacaoHistoriaRepository implements PanacheRepository<PublicacaoHistoria> {

    public record MarcoColecaoOriginal(
            Long serieId,
            String titulo,
            Integer volume,
            String editora,
            Long edicaoBrasileiraId,
            String edicaoBrasileiraNumero,
            LocalDate dataPublicacaoBrasileira,
            String edicaoOriginalNumero,
            double edicaoOriginalNumerica) {
    }

    private final EntityManager entityManager;

    public PublicacaoHistoriaRepository(EntityManager entityManager) {
        this.entityManager = entityManager;
    }

    public boolean existePorHistoriaEEdicaoPublicada(Long historiaId, Long edicaoPublicadaId) {
        return buscarPorHistoriaEEdicaoPublicada(historiaId, edicaoPublicadaId).isPresent();
    }

    public Optional<PublicacaoHistoria> buscarPorHistoriaEEdicaoPublicada(Long historiaId, Long edicaoPublicadaId) {
        return find("historia.id = ?1 and edicaoPublicada.id = ?2", historiaId, edicaoPublicadaId)
                .firstResultOptional();
    }

    public List<PublicacaoHistoria> listarPorHistoria(Long historiaId) {
        return list("historia.id = ?1 order by edicaoPublicada.dataPublicacao asc", historiaId);
    }

    public List<PublicacaoHistoria> listarPorEdicaoOriginalEPublicada(Long edicaoOriginalId, Long edicaoPublicadaId) {
        return list("edicaoOriginal.id = ?1 and edicaoPublicada.id = ?2 order by historia.titulo asc",
                edicaoOriginalId, edicaoPublicadaId);
    }

    public List<PublicacaoHistoria> listarPorEdicaoPublicada(Long edicaoPublicadaId) {
        return list("""
                edicaoPublicada.id = ?1
                and edicaoOriginal.id <> edicaoPublicada.id
                and not (
                    lower(edicaoOriginal.numero) = lower(edicaoPublicada.numero)
                    and lower(edicaoOriginal.serie.titulo) = lower(edicaoPublicada.serie.titulo)
                )
                order by historia.titulo asc
                """,
                edicaoPublicadaId);
    }

    public List<PublicacaoHistoria> listarPorEdicaoOriginal(Long edicaoOriginalId) {
        return list("""
                edicaoOriginal.id = ?1
                and edicaoPublicada.id <> edicaoOriginal.id
                and not (
                    lower(edicaoOriginal.numero) = lower(edicaoPublicada.numero)
                    and lower(edicaoOriginal.serie.titulo) = lower(edicaoPublicada.serie.titulo)
                )
                order by edicaoPublicada.dataPublicacao asc, edicaoPublicada.numero asc, historia.titulo asc
                """,
                edicaoOriginalId);
    }

    public List<PublicacaoHistoria> listarPublicacoesBrasileirasComDados(List<Long> edicoesOriginais) {
        return entityManager.createQuery("""
                select p
                  from PublicacaoHistoria p
                  join fetch p.historia historia
                  join fetch p.edicaoOriginal original
                  join fetch original.serie serieOriginal
                  join fetch serieOriginal.editora editoraOriginal
                  join fetch p.edicaoPublicada publicada
                  join fetch publicada.serie seriePublicada
                  join fetch seriePublicada.editora editoraPublicada
                 where original.id in :edicoesOriginais
                   and publicada.id <> original.id
                   and seriePublicada.tipoSerie = br.com.hqhub.entity.TipoSerie.BRASILEIRA
                 order by coalesce(publicada.dataPublicacao, publicada.dataCobertura) asc,
                          publicada.id asc, lower(historia.titulo) asc
                """, PublicacaoHistoria.class)
                .setParameter("edicoesOriginais", edicoesOriginais)
                .getResultList();
    }

    public List<PublicacaoHistoria> listarPorHistoriasDaEdicao(Long edicaoId) {
        return entityManager.createQuery("""
                select p
                  from PublicacaoHistoria p
                  join fetch p.historia
                  join fetch p.edicaoPublicada publicada
                  join fetch publicada.serie serie
                  join fetch serie.editora
                 where p.historia.id in (select conteudo.historia.id from ConteudoEdicao conteudo where conteudo.edicao.id = :edicaoId)
                   and p.edicaoPublicada.id <> :edicaoId
                   and serie.tipoSerie = br.com.hqhub.entity.TipoSerie.BRASILEIRA
                 order by coalesce(publicada.dataPublicacao, publicada.dataCobertura) asc, publicada.id asc
                """, PublicacaoHistoria.class)
                .setParameter("edicaoId", edicaoId)
                .getResultList();
    }

    public List<MarcoColecaoOriginal> listarMarcosColecoesPorVolumeComicVine(String idVolume) {
        String volumeNormalizado = idVolume == null ? "" : idVolume.replaceFirst("^4050-", "");
        List<?> linhas = entityManager.createNativeQuery("""
                with series_originais as (
                    select distinct serie.id
                      from series serie
                      join editoras editora on editora.id = serie.editora_id
                     where serie.tipo_serie = 'ESTRANGEIRA'
                       and (
                           (upper(coalesce(serie.fonte_externa, '')) = 'COMICVINE'
                            and regexp_replace(coalesce(serie.id_externo, ''), '^4050-', '') = :idVolume)
                           or exists (
                               select 1
                                 from correspondencias_series_externas correspondencia
                                where correspondencia.fonte_externa = 'COMICVINE'
                                  and regexp_replace(correspondencia.id_volume, '^4050-', '') = :idVolume
                                  and hqhub_normalizar_titulo_serie(correspondencia.titulo_catalogo) = hqhub_normalizar_titulo_serie(serie.titulo)
                                  and hqhub_normalizar_titulo_serie(correspondencia.editora) = hqhub_normalizar_titulo_serie(editora.nome)
                                  and correspondencia.ano_inicio = serie.ano_inicio
                           )
                       )
                )
                select distinct
                       serie_brasileira.id,
                       serie_brasileira.titulo,
                       serie_brasileira.volume,
                       editora_brasileira.nome,
                       edicao_brasileira.id,
                       edicao_brasileira.numero,
                       coalesce(edicao_brasileira.data_publicacao, edicao_brasileira.data_cobertura),
                       edicao_original.numero,
                       cast(substring(edicao_original.numero from '^[0-9]+') as double precision)
                  from publicacoes_historias publicacao
                  join edicoes edicao_original on edicao_original.id = publicacao.edicao_original_id
                  join edicoes edicao_brasileira on edicao_brasileira.id = publicacao.edicao_publicada_id
                  join series serie_brasileira on serie_brasileira.id = edicao_brasileira.serie_id
                  join editoras editora_brasileira on editora_brasileira.id = serie_brasileira.editora_id
                 where edicao_original.serie_id in (select id from series_originais)
                   and serie_brasileira.tipo_serie = 'BRASILEIRA'
                   and edicao_brasileira.id <> edicao_original.id
                   and edicao_original.numero ~ '^[0-9]'
                 order by serie_brasileira.titulo, serie_brasileira.volume,
                          coalesce(edicao_brasileira.data_publicacao, edicao_brasileira.data_cobertura),
                          edicao_brasileira.id, 9
                """)
                .setParameter("idVolume", volumeNormalizado)
                .getResultList();

        return linhas.stream().map(linha -> {
            Object[] valores = (Object[]) linha;
            LocalDate data = valores[6] instanceof java.sql.Date dataSql
                    ? dataSql.toLocalDate()
                    : (LocalDate) valores[6];
            return new MarcoColecaoOriginal(
                    ((Number) valores[0]).longValue(),
                    (String) valores[1],
                    valores[2] == null ? null : ((Number) valores[2]).intValue(),
                    (String) valores[3],
                    ((Number) valores[4]).longValue(),
                    (String) valores[5],
                    data,
                    (String) valores[7],
                    ((Number) valores[8]).doubleValue());
        }).toList();
    }
}
