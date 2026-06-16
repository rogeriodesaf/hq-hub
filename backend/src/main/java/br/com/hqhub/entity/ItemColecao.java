package br.com.hqhub.entity;

import java.math.BigDecimal;
import java.time.LocalDate;
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
@Table(name = "itens_colecao", uniqueConstraints = {
        @UniqueConstraint(name = "uk_itens_colecao_usuario_edicao", columnNames = { "usuario_id", "edicao_id" })
})
@Getter
@Setter
public class ItemColecao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario usuario;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "edicao_id", nullable = false)
    private Edicao edicao;

    @Enumerated(EnumType.STRING)
    @Column(name = "estado_conservacao", nullable = false)
    private EstadoConservacao estadoConservacao;

    @Column(name = "data_aquisicao")
    private LocalDate dataAquisicao;

    @Column(name = "preco_pago", precision = 10, scale = 2)
    private BigDecimal precoPago;

    @Column(length = 1000)
    private String observacoes;

    @Column(name = "data_criacao", nullable = false)
    @CreationTimestamp
    private LocalDateTime dataCriacao;

    @Column(name = "data_atualizacao", nullable = false)
    @UpdateTimestamp
    private LocalDateTime dataAtualizacao;
}
