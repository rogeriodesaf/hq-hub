ALTER TABLE postagens_feed
    ADD COLUMN IF NOT EXISTS serie_catalogo_id BIGINT;

ALTER TABLE postagens_feed
    ADD CONSTRAINT fk_postagens_feed_serie_catalogo
    FOREIGN KEY (serie_catalogo_id)
    REFERENCES series(id)
    ON DELETE SET NULL;

UPDATE postagens_feed postagem
   SET serie_catalogo_id = (
       SELECT serie.id
         FROM series serie
        WHERE postagem.sistema = TRUE
          AND lower(postagem.conteudo) LIKE '%' || lower(serie.titulo) || '%'
        ORDER BY length(serie.titulo) DESC, serie.id
        LIMIT 1
   )
 WHERE postagem.serie_catalogo_id IS NULL
   AND postagem.sistema = TRUE
   AND lower(postagem.conteudo) LIKE '% no nosso catalogo.%';
