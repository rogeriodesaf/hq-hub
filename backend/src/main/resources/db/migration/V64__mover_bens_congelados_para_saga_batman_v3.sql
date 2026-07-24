DO $$
DECLARE
    serie_canonica_id BIGINT;
    serie_errada RECORD;
BEGIN
    SELECT s.id
      INTO serie_canonica_id
      FROM series s
      JOIN editoras e ON e.id = s.editora_id
     WHERE hqhub_normalizar_titulo_serie(s.titulo) =
           hqhub_normalizar_titulo_serie('A Saga do Batman')
       AND lower(e.nome) = 'panini'
       AND s.volume = 3
     ORDER BY
       CASE WHEN lower(s.titulo) = lower('A Saga do Batman') THEN 0 ELSE 1 END,
       (SELECT count(*) FROM edicoes ed WHERE ed.serie_id = s.id) DESC,
       s.id
     LIMIT 1;

    IF serie_canonica_id IS NULL THEN
        RETURN;
    END IF;

    FOR serie_errada IN
        SELECT s.id
          FROM series s
          JOIN editoras e ON e.id = s.editora_id
         WHERE hqhub_normalizar_identidade(s.titulo) =
               hqhub_normalizar_identidade('Saga do Batman, A 3ª Temporada')
           AND lower(e.nome) = 'panini'
           AND s.volume = 3
           AND s.id <> serie_canonica_id
    LOOP
        UPDATE edicoes ed
           SET serie_id = serie_canonica_id,
               data_atualizacao = CURRENT_TIMESTAMP
         WHERE ed.serie_id = serie_errada.id
           AND hqhub_normalizar_identidade(ed.numero) = '4'
           AND NOT EXISTS (
                   SELECT 1
                     FROM edicoes existente
                    WHERE existente.serie_id = serie_canonica_id
                      AND hqhub_normalizar_identidade(existente.numero) = '4'
               );

        IF NOT EXISTS (SELECT 1 FROM edicoes ed WHERE ed.serie_id = serie_errada.id) THEN
            DELETE FROM colecoes_series descartada
             USING colecoes_series mantida
             WHERE descartada.serie_id = serie_errada.id
               AND mantida.serie_id = serie_canonica_id
               AND descartada.usuario_id = mantida.usuario_id;

            UPDATE colecoes_series
               SET serie_id = serie_canonica_id,
                   data_atualizacao = CURRENT_TIMESTAMP
             WHERE serie_id = serie_errada.id;

            DELETE FROM relacionamentos_series
             WHERE (serie_origem_id = serie_errada.id AND serie_destino_id = serie_canonica_id)
                OR (serie_origem_id = serie_canonica_id AND serie_destino_id = serie_errada.id);

            DELETE FROM relacionamentos_series descartada
             USING relacionamentos_series mantida
             WHERE descartada.serie_origem_id = serie_errada.id
               AND mantida.serie_origem_id = serie_canonica_id
               AND descartada.serie_destino_id = mantida.serie_destino_id
               AND descartada.tipo = mantida.tipo;

            UPDATE relacionamentos_series
               SET serie_origem_id = serie_canonica_id
             WHERE serie_origem_id = serie_errada.id;

            DELETE FROM relacionamentos_series descartada
             USING relacionamentos_series mantida
             WHERE descartada.serie_destino_id = serie_errada.id
               AND mantida.serie_destino_id = serie_canonica_id
               AND descartada.serie_origem_id = mantida.serie_origem_id
               AND descartada.tipo = mantida.tipo;

            UPDATE relacionamentos_series
               SET serie_destino_id = serie_canonica_id
             WHERE serie_destino_id = serie_errada.id;

            DELETE FROM relacionamentos_series duplicada
             USING relacionamentos_series mantida
             WHERE duplicada.id > mantida.id
               AND duplicada.serie_origem_id = mantida.serie_origem_id
               AND duplicada.serie_destino_id = mantida.serie_destino_id
               AND duplicada.tipo = mantida.tipo;

            DELETE FROM series WHERE id = serie_errada.id;
        END IF;
    END LOOP;
END $$;
