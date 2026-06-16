package br.com.hqhub.entity;

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
@Table(name = "series", uniqueConstraints = {
        @UniqueConstraint(name = "uk_series_titulo_editora", columnNames = { "titulo", "editora_id" })
})
@Getter
@Setter
public class Serie {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String titulo;

    @Column(length = 1000)
    private String descricao;

    @Column(name = "ano_inicio")
    private Integer anoInicio;

    @Column(name = "ano_fim")
    private Integer anoFim;

    private Integer volume;

    @Column(name = "ordem_cronologica")
    private Integer ordemCronologica;

    @Column(name = "fonte_externa")
    private String fonteExterna;

    @Column(name = "id_externo")
    private String idExterno;

    @Column(name = "url_origem", length = 1000)
    private String urlOrigem;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "editora_id", nullable = false)
    private Editora editora;

    @Column(name = "data_criacao", nullable = false)
    @CreationTimestamp
    private LocalDateTime dataCriacao;

    @Column(name = "data_atualizacao", nullable = false)
    @UpdateTimestamp
    private LocalDateTime dataAtualizacao;
}
