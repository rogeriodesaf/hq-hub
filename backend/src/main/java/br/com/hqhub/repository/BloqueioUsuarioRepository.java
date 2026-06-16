package br.com.hqhub.repository;

import java.util.List;
import java.util.Optional;

import br.com.hqhub.entity.BloqueioUsuario;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class BloqueioUsuarioRepository implements PanacheRepository<BloqueioUsuario> {

    public boolean existeBloqueioEntre(Long usuarioId, Long outroUsuarioId) {
        return find("(usuario.id = ?1 and usuarioBloqueado.id = ?2) or (usuario.id = ?2 and usuarioBloqueado.id = ?1)",
                usuarioId, outroUsuarioId)
                .firstResultOptional()
                .isPresent();
    }

    public Optional<BloqueioUsuario> buscarPorUsuarioEBloqueado(Long usuarioId, Long usuarioBloqueadoId) {
        return find("usuario.id = ?1 and usuarioBloqueado.id = ?2", usuarioId, usuarioBloqueadoId).firstResultOptional();
    }

    public List<BloqueioUsuario> listarPorUsuario(Long usuarioId) {
        return list("usuario.id = ?1 order by dataBloqueio desc", usuarioId);
    }
}
