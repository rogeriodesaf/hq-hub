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
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "contribuicoes_catalogo")
@Getter
@Setter
public class ContribuicaoCatalogo {

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
    @Column(nullable = false)
    private TipoContribuicaoCatalogo tipo;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatusContribuicaoCatalogo status;

    @Column(name = "url_capa_sugerida", length = 1000)
    private String urlCapaSugerida;

    @Column(name = "edicao_destino_id")
    private Long edicaoDestinoId;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_publicacao_relacionada")
    private TipoPublicacaoRelacionada tipoPublicacaoRelacionada;

    @Column(name = "fonte_externa")
    private String fonteExterna;

    @Column(name = "url_fonte", length = 1000)
    private String urlFonte;

    @Column(name = "dados_sugeridos_json", columnDefinition = "TEXT")
    private String dadosSugeridosJson;

    @Column(length = 1000)
    private String observacoes;

    @Column(name = "mensagem_revisao", length = 1000)
    private String mensagemRevisao;

    @Column(name = "data_revisao")
    private LocalDateTime dataRevisao;

    @Column(name = "data_criacao", nullable = false)
    @CreationTimestamp
    private LocalDateTime dataCriacao;

    @Column(name = "data_atualizacao", nullable = false)
    @UpdateTimestamp
    private LocalDateTime dataAtualizacao;
}
