package br.com.hqhub.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "itens_ordem_leitura", uniqueConstraints =
        @UniqueConstraint(name = "uk_item_ordem_posicao", columnNames = {"ordem_leitura_id", "posicao"}))
@Getter @Setter
public class ItemOrdemLeitura {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "ordem_leitura_id", nullable = false) private OrdemLeitura ordemLeitura;
    @Column(nullable = false) private Integer posicao;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "edicao_id") private Edicao edicao;
    @Column(name = "titulo_referencia", nullable = false) private String tituloReferencia;
    @Column(name = "detalhe_referencia") private String detalheReferencia;
    @Column(name = "url_capa_referencia", length = 1000) private String urlCapaReferencia;
}
