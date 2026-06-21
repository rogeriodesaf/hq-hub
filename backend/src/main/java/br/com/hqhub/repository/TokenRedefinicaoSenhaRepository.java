package br.com.hqhub.repository;

import br.com.hqhub.entity.TokenRedefinicaoSenha;
import br.com.hqhub.entity.Usuario;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

import java.util.Optional;

@ApplicationScoped
public class TokenRedefinicaoSenhaRepository implements PanacheRepository<TokenRedefinicaoSenha> {

    public Optional<TokenRedefinicaoSenha> buscarPorToken(String token) {
        return find("token", token).firstResultOptional();
    }

    public void excluirPorUsuario(Usuario usuario) {
        delete("usuario", usuario);
    }
}
