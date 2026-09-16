package br.com.hqhub.entity;

import java.time.LocalDateTime;
import org.hibernate.annotations.CreationTimestamp;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "notificacoes_sociais")
@Getter
@Setter
public class NotificacaoSocial {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "destinatario_id", nullable = false)
    private Usuario destinatario;
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "autor_id", nullable = false)
    private Usuario autor;
    @Enumerated(EnumType.STRING) @Column(nullable = false, length = 40)
    private TipoNotificacaoSocial tipo;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "postagem_id")
    private PostagemFeed postagem;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "comentario_id")
    private ComentarioFeed comentario;
    @Column(nullable = false, length = 500)
    private String mensagem;
    @Column(nullable = false)
    private boolean lida;
    @CreationTimestamp @Column(name = "data_criacao", nullable = false)
    private LocalDateTime dataCriacao;
}
