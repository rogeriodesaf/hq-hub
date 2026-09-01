package br.com.hqhub.repository;

import java.util.List;
import java.util.Optional;

import br.com.hqhub.entity.PublicacaoHistoria;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.persistence.EntityManager;

@ApplicationScoped
public class PublicacaoHistoriaRepository implements PanacheRepository<PublicacaoHistoria> {

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

    public List<PublicacaoHistoria> listarPublicacoesBrasileirasComDados(Long edicaoOriginalId) {
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
                 where original.id = :edicaoOriginalId
                   and publicada.id <> original.id
                   and seriePublicada.tipoSerie = br.com.hqhub.entity.TipoSerie.BRASILEIRA
                 order by coalesce(publicada.dataPublicacao, publicada.dataCobertura) asc,
                          publicada.id asc, lower(historia.titulo) asc
                """, PublicacaoHistoria.class)
                .setParameter("edicaoOriginalId", edicaoOriginalId)
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
}
