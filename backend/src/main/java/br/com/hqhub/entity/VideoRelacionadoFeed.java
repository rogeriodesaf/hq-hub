package br.com.hqhub.entity;

import java.time.LocalDateTime;
import java.util.UUID;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UuidGenerator;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "videos_relacionados_feed", uniqueConstraints = {
        @UniqueConstraint(name = "uk_videos_relacionados_postagem_ordem", columnNames = { "postagem_id", "ordem" })
})
@Getter
@Setter
public class VideoRelacionadoFeed {

    @Id
    @UuidGenerator
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "postagem_id", nullable = false)
    private PostagemFeed postagem;

    @Column(nullable = false, length = 200)
    private String titulo;

    @Column(nullable = false, length = 1000)
    private String url;

    @Column(length = 1000)
    private String thumbnail;

    @Column(name = "nome_canal", length = 200)
    private String nomeCanal;

    @Column(name = "duracao_segundos")
    private Integer duracaoSegundos;

    private Long visualizacoes;

    @Column(nullable = false)
    private Integer ordem;

    @CreationTimestamp
    @Column(name = "data_criacao", nullable = false)
    private LocalDateTime dataCriacao;
}
