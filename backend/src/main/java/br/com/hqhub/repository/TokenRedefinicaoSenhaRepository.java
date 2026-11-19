package br.com.hqhub.repository;

import br.com.hqhub.entity.TokenRedefinicaoSenha;
import br.com.hqhub.entity.Usuario;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.persistence.LockModeType;

import java.time.LocalDateTime;
import java.util.Optional;

@ApplicationScoped
public class TokenRedefinicaoSenhaRepository implements PanacheRepository<TokenRedefinicaoSenha> {

    public Optional<TokenRedefinicaoSenha> buscarPorToken(String token) {
        return find("token", token).firstResultOptional();
    }

    public Optional<TokenRedefinicaoSenha> buscarPorTokenParaConsumo(String token) {
        return find("token", token).withLock(LockModeType.PESSIMISTIC_WRITE).firstResultOptional();
    }

    public boolean existeRecentePorUsuario(Usuario usuario, LocalDateTime limiteExpiracao) {
        return count("usuario = ?1 and expiraEm > ?2", usuario, limiteExpiracao) > 0;
    }

    public void excluirPorUsuario(Usuario usuario) {
        delete("usuario", usuario);
    }
}
