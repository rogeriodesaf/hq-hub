package br.com.hqhub.entity;

import java.time.LocalDateTime;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "relacionamentos_series", uniqueConstraints = {
        @UniqueConstraint(name = "uk_relacionamentos_series_origem_destino_tipo", columnNames = { "serie_origem_id", "serie_destino_id", "tipo" })
})
@Getter
@Setter
public class RelacionamentoSerie {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "serie_origem_id", nullable = false)
    private Serie serieOrigem;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "serie_destino_id", nullable = false)
    private Serie serieDestino;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TipoRelacionamentoSerie tipo;

    @Column(length = 500)
    private String observacoes;

    @Column(name = "data_criacao", nullable = false)
    @CreationTimestamp
    private LocalDateTime dataCriacao;

    @Column(name = "data_atualizacao", nullable = false)
    @UpdateTimestamp
    private LocalDateTime dataAtualizacao;
}
