package br.com.hqhub.entity;

import java.time.LocalDateTime;

import org.hibernate.annotations.CreationTimestamp;

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
@Table(name = "edicoes_atividades_estante", uniqueConstraints = {
        @UniqueConstraint(name = "uk_atividade_estante_postagem_edicao", columnNames = { "postagem_id", "edicao_id" })
})
@Getter
@Setter
public class EdicaoAtividadeEstante {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "postagem_id", nullable = false)
    private PostagemFeed postagem;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "edicao_id")
    private Edicao edicao;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "item_colecao_id")
    private ItemColecao itemColecao;

    @Column(name = "titulo_snapshot", nullable = false, length = 500)
    private String tituloSnapshot;

    @Column(name = "url_capa_snapshot", length = 1000)
    private String urlCapaSnapshot;

    @CreationTimestamp
    @Column(name = "data_criacao", nullable = false)
    private LocalDateTime dataCriacao;
}
