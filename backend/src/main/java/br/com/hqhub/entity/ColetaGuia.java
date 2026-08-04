package br.com.hqhub.entity;

import java.time.LocalDateTime;
import java.util.UUID;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.annotations.UuidGenerator;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "coletas_guia")
@Getter
@Setter
public class ColetaGuia {

    @Id
    @UuidGenerator
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario usuario;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private StatusColetaGuia status;

    @Column(name = "pedido_json", nullable = false, columnDefinition = "TEXT")
    private String pedidoJson;

    @Column(name = "urls_json", nullable = false, columnDefinition = "TEXT")
    private String urlsJson;

    @Column(name = "edicoes_json", nullable = false, columnDefinition = "TEXT")
    private String edicoesJson;

    @Column(name = "avisos_json", nullable = false, columnDefinition = "TEXT")
    private String avisosJson;

    @Column(name = "resultado_json", columnDefinition = "TEXT")
    private String resultadoJson;

    @Column(name = "total_paginas", nullable = false)
    private Integer totalPaginas;

    @Column(name = "paginas_processadas", nullable = false)
    private Integer paginasProcessadas;

    @Column(name = "paginas_no_lote", nullable = false)
    private Integer paginasNoLote;

    @Column(name = "falhas_consecutivas", nullable = false)
    private Integer falhasConsecutivas;

    @Column(name = "proxima_execucao")
    private LocalDateTime proximaExecucao;

    @Column(length = 1000)
    private String mensagem;

    @CreationTimestamp
    @Column(name = "data_criacao", nullable = false)
    private LocalDateTime dataCriacao;

    @UpdateTimestamp
    @Column(name = "data_atualizacao", nullable = false)
    private LocalDateTime dataAtualizacao;
}
