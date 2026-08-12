package br.com.hqhub.entity;

import java.io.Serializable;
import java.time.LocalDateTime;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "progresso_ordem_leitura")
@IdClass(ProgressoOrdemLeitura.Chave.class)
@Getter @Setter
public class ProgressoOrdemLeitura {
    @Id @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "usuario_id") private Usuario usuario;
    @Id @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "item_ordem_leitura_id") private ItemOrdemLeitura item;
    @Column(nullable = false) private boolean lido;
    @Column(name = "data_atualizacao", nullable = false) private LocalDateTime dataAtualizacao;

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor
    public static class Chave implements Serializable {
        private Long usuario;
        private Long item;
    }
}
