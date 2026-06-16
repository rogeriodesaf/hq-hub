package br.com.hqhub.entity;

import java.time.LocalDateTime;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "historias")
@Getter
@Setter
public class Historia {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String titulo;

    @Column(name = "titulo_original")
    private String tituloOriginal;

    @Column(length = 2000)
    private String descricao;

    @Column(name = "quantidade_paginas")
    private Integer quantidadePaginas;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TipoConteudoEdicao tipo;

    @Column(name = "fonte_externa")
    private String fonteExterna;

    @Column(name = "id_externo")
    private String idExterno;

    @Column(name = "url_origem", length = 1000)
    private String urlOrigem;

    @Column(name = "data_criacao", nullable = false)
    @CreationTimestamp
    private LocalDateTime dataCriacao;

    @Column(name = "data_atualizacao", nullable = false)
    @UpdateTimestamp
    private LocalDateTime dataAtualizacao;
}
