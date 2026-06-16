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
@Table(name = "publicacoes_relacionadas", uniqueConstraints = {
        @UniqueConstraint(name = "uk_publicacoes_relacionadas_origem_destino_tipo", columnNames = {
                "edicao_origem_id", "edicao_destino_id", "tipo" })
})
@Getter
@Setter
public class PublicacaoRelacionada {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "edicao_origem_id", nullable = false)
    private Edicao edicaoOrigem;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "edicao_destino_id", nullable = false)
    private Edicao edicaoDestino;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TipoPublicacaoRelacionada tipo;

    @Column(name = "fonte_externa")
    private String fonteExterna;

    @Column(name = "url_origem", length = 1000)
    private String urlOrigem;

    @Column(length = 1000)
    private String observacoes;

    @Column(name = "data_criacao", nullable = false)
    @CreationTimestamp
    private LocalDateTime dataCriacao;

    @Column(name = "data_atualizacao", nullable = false)
    @UpdateTimestamp
    private LocalDateTime dataAtualizacao;
}
