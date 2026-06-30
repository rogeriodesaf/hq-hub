package br.com.hqhub.entity;

import java.time.LocalDateTime;

import org.hibernate.annotations.CreationTimestamp;

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
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "capas_edicao")
@Getter
@Setter
public class CapaEdicao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "edicao_id", nullable = false)
    private Edicao edicao;

    @Column(name = "url_imagem", nullable = false, length = 1000)
    private String urlImagem;

    @Column(name = "public_id_cloudinary", length = 500)
    private String publicIdCloudinary;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "enviado_por_usuario_id")
    private Usuario enviadoPorUsuario;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private StatusCapaEdicao status = StatusCapaEdicao.PENDENTE;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 40)
    private OrigemCapaEdicao origem;

    @Column(length = 1000)
    private String observacao;

    @Column(name = "data_envio", nullable = false)
    @CreationTimestamp
    private LocalDateTime dataEnvio;

    @Column(name = "data_aprovacao")
    private LocalDateTime dataAprovacao;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "aprovado_por_usuario_id")
    private Usuario aprovadoPorUsuario;
}
