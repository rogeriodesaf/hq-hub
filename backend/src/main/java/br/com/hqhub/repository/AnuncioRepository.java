package br.com.hqhub.repository;

import java.util.List;

import br.com.hqhub.entity.Anuncio;
import br.com.hqhub.entity.StatusAnuncio;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class AnuncioRepository implements PanacheRepository<Anuncio> {

    public List<Anuncio> listarAtivos() {
        return list("status = ?1 order by dataCriacao desc", StatusAnuncio.ATIVO);
    }

    public List<Anuncio> listarAtivosPorEdicao(Long edicaoId) {
        return list("itemColecao.edicao.id = ?1 and status = ?2 order by dataCriacao desc", edicaoId, StatusAnuncio.ATIVO);
    }

    public List<Anuncio> listarAtivosPorUsuario(Long usuarioId) {
        return list("anunciante.id = ?1 and status = ?2 order by dataCriacao desc", usuarioId, StatusAnuncio.ATIVO);
    }

    public List<Anuncio> listarDoUsuario(Long usuarioId) {
        return list("anunciante.id = ?1 and status <> ?2 order by dataCriacao desc", usuarioId, StatusAnuncio.REMOVIDO);
    }

    public boolean existeAnuncioAtivoParaItem(Long itemColecaoId) {
        return find("itemColecao.id = ?1 and status in (?2, ?3)", itemColecaoId, StatusAnuncio.ATIVO, StatusAnuncio.PAUSADO)
                .firstResultOptional()
                .isPresent();
    }
}
