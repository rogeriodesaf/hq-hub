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
import jakarta.persistence.UniqueConstraint;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "amizades", uniqueConstraints = {
        @UniqueConstraint(name = "uk_amizades_solicitante_solicitado", columnNames = { "solicitante_id", "solicitado_id" })
})
@Getter
@Setter
public class Amizade {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "solicitante_id", nullable = false)
    private Usuario solicitante;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "solicitado_id", nullable = false)
    private Usuario solicitado;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private StatusAmizade status;

    @Column(name = "data_solicitacao", nullable = false)
    @CreationTimestamp
    private LocalDateTime dataSolicitacao;

    @Column(name = "data_resposta")
    private LocalDateTime dataResposta;
}
