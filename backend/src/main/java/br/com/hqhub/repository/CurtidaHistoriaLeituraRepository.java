package br.com.hqhub.repository;

import java.util.Optional;
import br.com.hqhub.entity.CurtidaHistoriaLeitura;
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class CurtidaHistoriaLeituraRepository implements PanacheRepository<CurtidaHistoriaLeitura> {
    public Optional<CurtidaHistoriaLeitura> buscar(Long historiaId, Long usuarioId) { return find("historia.id = ?1 and usuario.id = ?2", historiaId, usuarioId).firstResultOptional(); }
    public long total(Long historiaId) { return count("historia.id = ?1", historiaId); }
}
