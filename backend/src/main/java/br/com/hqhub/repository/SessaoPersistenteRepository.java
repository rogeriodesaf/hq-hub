package br.com.hqhub.repository;

import java.time.LocalDateTime;

import br.com.hqhub.entity.SessaoPersistente;
import br.com.hqhub.entity.Usuario;
import io.quarkus.hibernate.orm.panache.PanacheRepositoryBase;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class SessaoPersistenteRepository implements PanacheRepositoryBase<SessaoPersistente, String> {
    public void removerExpiradas() {
        delete("expiraEm < ?1", LocalDateTime.now());
    }

    public void revogarPorUsuario(Usuario usuario) {
        delete("usuario", usuario);
    }
}
