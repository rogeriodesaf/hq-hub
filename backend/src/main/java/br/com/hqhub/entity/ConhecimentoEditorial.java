package br.com.hqhub.entity;

import java.time.LocalDateTime;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

@Entity
@Table(name = "conhecimentos_editoriais")
public class ConhecimentoEditorial extends PanacheEntity {

    @Column(length = 50, nullable = false)
    public String tipo; // SAGA, HEROI, AUTOR, ARCO, CURIOSIDADE

    @Column(nullable = false)
    public String titulo;

    @Column(columnDefinition = "TEXT", nullable = false)
    public String conteudo;

    @Column(length = 255)
    public String fonte; // URL ou referência

    @Column(length = 255)
    public String urlFonte;

    @Column(length = 50)
    public String confianca; // VERIFICADA, OFICIAL, COMUNITARIA

    @Column(nullable = false)
    public LocalDateTime dataCriacao;

    @Column(nullable = false)
    public LocalDateTime dataAtualizacao;

    @Column(length = 100)
    public String origemDados; // MANUAL, COMIC_VINE, SCRAPING, IMPORTACAO

    @Column(length = 500)
    public String tags; // separadas por vírgula

    @Column(length = 500)
    public String relacionadas; // IDs de conhecimentos relacionados

    public ConhecimentoEditorial() {
        this.dataCriacao = LocalDateTime.now();
        this.dataAtualizacao = LocalDateTime.now();
        this.confianca = "COMUNITARIA";
    }

    public ConhecimentoEditorial(String tipo, String titulo, String conteudo, String fonte, String urlFonte,
            String origemDados) {
        this();
        this.tipo = tipo;
        this.titulo = titulo;
        this.conteudo = conteudo;
        this.fonte = fonte;
        this.urlFonte = urlFonte;
        this.origemDados = origemDados;
    }
}
