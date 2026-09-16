package br.com.hqhub.entity;

import java.time.LocalDateTime;
import org.hibernate.annotations.CreationTimestamp;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "visualizacoes_historia_leitura", uniqueConstraints = @UniqueConstraint(columnNames = {"historia_id", "usuario_id"}))
@Getter
@Setter
public class VisualizacaoHistoriaLeitura {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "historia_id", nullable = false)
    private HistoriaLeitura historia;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario usuario;

    @CreationTimestamp
    @Column(name = "data_visualizacao", nullable = false)
    private LocalDateTime dataVisualizacao;
}
