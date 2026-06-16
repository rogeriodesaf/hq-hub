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
@Table(name = "publicacoes_historias", uniqueConstraints = {
        @UniqueConstraint(name = "uk_publicacoes_historias_historia_edicao", columnNames = { "historia_id", "edicao_publicada_id" })
})
@Getter
@Setter
public class PublicacaoHistoria {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "historia_id", nullable = false)
    private Historia historia;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "edicao_original_id", nullable = false)
    private Edicao edicaoOriginal;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "edicao_publicada_id", nullable = false)
    private Edicao edicaoPublicada;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatusPublicacaoHistoria status;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_publicacao_historia", nullable = false)
    private TipoPublicacaoHistoria tipoPublicacaoHistoria = TipoPublicacaoHistoria.REPUBLICACAO;

    @Column(name = "fonte_informacao")
    private String fonteInformacao;

    @Column(name = "url_fonte_informacao", length = 1000)
    private String urlFonteInformacao;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_criador_id")
    private Usuario usuarioCriador;

    @Enumerated(EnumType.STRING)
    @Column(name = "status_validacao", nullable = false)
    private StatusValidacao statusValidacao = StatusValidacao.PENDENTE;

    @Column(name = "titulo_usado")
    private String tituloUsado;

    @Column(name = "paginas_publicadas")
    private Integer paginasPublicadas;

    @Column(name = "paginas_cortadas")
    private Integer paginasCortadas;

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
