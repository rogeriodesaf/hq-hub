package br.com.hqhub.repository;

import java.util.List;

import br.com.hqhub.entity.Edicao;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.quarkus.panache.common.Page;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class EdicaoRepository implements PanacheRepository<Edicao> {

    public boolean existePorNumeroESerie(String numero, Long serieId) {
        return find("lower(numero) = ?1 and serie.id = ?2", numero.toLowerCase(), serieId)
                .firstResultOptional()
                .isPresent();
    }

    public boolean existePorNumeroESerieEmOutraEdicao(String numero, Long serieId, Long id) {
        return find("lower(numero) = ?1 and serie.id = ?2 and id <> ?3", numero.toLowerCase(), serieId, id)
                .firstResultOptional()
                .isPresent();
    }

    public boolean existePorOrigemExterna(String fonteExterna, String idExterno) {
        if (fonteExterna == null || idExterno == null) {
            return false;
        }

        return find("fonteExterna = ?1 and idExterno = ?2", fonteExterna, idExterno)
                .firstResultOptional()
                .isPresent();
    }

    public boolean existePorOrigemExternaEmOutraEdicao(String fonteExterna, String idExterno, Long id) {
        if (fonteExterna == null || idExterno == null) {
            return false;
        }

        return find("fonteExterna = ?1 and idExterno = ?2 and id <> ?3", fonteExterna, idExterno, id)
                .firstResultOptional()
                .isPresent();
    }

    public List<Edicao> buscarPaginado(Long serieId, String busca, int pagina, int tamanho) {
        if (serieId != null && busca != null && !busca.isBlank()) {
            return find("serie.id = ?1 and (lower(numero) like ?2 or lower(titulo) like ?2) order by numero",
                    serieId, "%" + busca.toLowerCase() + "%")
                    .page(Page.of(pagina, tamanho))
                    .list();
        }

        if (serieId != null) {
            return find("serie.id = ?1 order by numero", serieId)
                    .page(Page.of(pagina, tamanho))
                    .list();
        }

        if (busca != null && !busca.isBlank()) {
            return find("lower(numero) like ?1 or lower(titulo) like ?1 order by numero", "%" + busca.toLowerCase() + "%")
                    .page(Page.of(pagina, tamanho))
                    .list();
        }

        return find("order by numero").page(Page.of(pagina, tamanho)).list();
    }

    public long contarComBusca(Long serieId, String busca) {
        if (serieId != null && busca != null && !busca.isBlank()) {
            return count("serie.id = ?1 and (lower(numero) like ?2 or lower(titulo) like ?2)",
                    serieId, "%" + busca.toLowerCase() + "%");
        }

        if (serieId != null) {
            return count("serie.id", serieId);
        }

        if (busca != null && !busca.isBlank()) {
            return count("lower(numero) like ?1 or lower(titulo) like ?1", "%" + busca.toLowerCase() + "%");
        }

        return count();
    }
}
