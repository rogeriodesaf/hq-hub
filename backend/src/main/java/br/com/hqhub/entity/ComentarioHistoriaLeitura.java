package br.com.hqhub.entity;

import java.time.LocalDateTime;
import org.hibernate.annotations.CreationTimestamp;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity @Table(name = "comentarios_historia_leitura") @Getter @Setter
public class ComentarioHistoriaLeitura {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "historia_id") private HistoriaLeitura historia;
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "usuario_id") private Usuario usuario;
    @Column(nullable = false, length = 500) private String texto;
    @CreationTimestamp @Column(name = "data_criacao", nullable = false) private LocalDateTime dataCriacao;
}
