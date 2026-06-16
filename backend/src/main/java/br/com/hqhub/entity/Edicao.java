package br.com.hqhub.entity;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
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
@Table(name = "edicoes", uniqueConstraints = {
        @UniqueConstraint(name = "uk_edicoes_numero_serie", columnNames = { "numero", "serie_id" })
})
@Getter
@Setter
public class Edicao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String numero;

    private String titulo;

    @Column(length = 2000)
    private String descricao;

    @Column(name = "data_publicacao")
    private LocalDate dataPublicacao;

    @Column(name = "url_capa", length = 1000)
    private String urlCapa;

    @Column(name = "codigo_barras")
    private String codigoBarras;

    @Column(name = "quantidade_paginas")
    private Integer quantidadePaginas;

    @Column(name = "preco_capa", precision = 10, scale = 2)
    private BigDecimal precoCapa;

    @Column(name = "fonte_externa")
    private String fonteExterna;

    @Column(name = "id_externo")
    private String idExterno;

    @Column(name = "url_origem", length = 1000)
    private String urlOrigem;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "serie_id", nullable = false)
    private Serie serie;

    @Column(name = "data_criacao", nullable = false)
    @CreationTimestamp
    private LocalDateTime dataCriacao;

    @Column(name = "data_atualizacao", nullable = false)
    @UpdateTimestamp
    private LocalDateTime dataAtualizacao;
}
