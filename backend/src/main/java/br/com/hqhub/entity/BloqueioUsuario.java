package br.com.hqhub.entity;

import java.time.LocalDateTime;

import org.hibernate.annotations.CreationTimestamp;

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
@Table(name = "bloqueios_usuarios", uniqueConstraints = {
        @UniqueConstraint(name = "uk_bloqueios_usuario_bloqueado", columnNames = { "usuario_id", "usuario_bloqueado_id" })
})
@Getter
@Setter
public class BloqueioUsuario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario usuario;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "usuario_bloqueado_id", nullable = false)
    private Usuario usuarioBloqueado;

    @Column(name = "data_bloqueio", nullable = false)
    @CreationTimestamp
    private LocalDateTime dataBloqueio;

    @Column(length = 500)
    private String motivo;
}
