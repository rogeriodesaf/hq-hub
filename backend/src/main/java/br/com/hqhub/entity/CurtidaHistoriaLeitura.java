package br.com.hqhub.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity @Table(name = "curtidas_historia_leitura", uniqueConstraints = @UniqueConstraint(columnNames = {"historia_id", "usuario_id"}))
@Getter @Setter
public class CurtidaHistoriaLeitura {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "historia_id") private HistoriaLeitura historia;
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "usuario_id") private Usuario usuario;
}
