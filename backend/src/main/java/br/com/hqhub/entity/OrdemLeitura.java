package br.com.hqhub.entity;

import java.time.LocalDateTime;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "ordens_leitura")
@Getter @Setter
public class OrdemLeitura {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(nullable = false, unique = true) private String slug;
    @Column(nullable = false) private String titulo;
    @Column(length = 1000) private String descricao;
    @Column(name = "url_capa", length = 1000) private String urlCapa;
    @Column(nullable = false) private boolean publicada = true;
    @CreationTimestamp @Column(name = "data_criacao", nullable = false) private LocalDateTime dataCriacao;
    @UpdateTimestamp @Column(name = "data_atualizacao", nullable = false) private LocalDateTime dataAtualizacao;
}
