DO $$
DECLARE
    serie_canonica_id BIGINT;
BEGIN
    SELECT s.id
      INTO serie_canonica_id
      FROM series s
      JOIN editoras e ON e.id = s.editora_id
     WHERE lower(s.titulo) = lower('Saga do Batman, A')
       AND lower(e.nome) = 'panini'
       AND s.volume = 3
     ORDER BY
       (SELECT count(*) FROM edicoes ed WHERE ed.serie_id = s.id) DESC,
       s.id
     LIMIT 1;

    IF serie_canonica_id IS NULL THEN
        RETURN;
    END IF;

    UPDATE edicoes ed
       SET serie_id = serie_canonica_id,
           data_atualizacao = CURRENT_TIMESTAMP
     WHERE ed.serie_id IN (
               SELECT s.id
                 FROM series s
                 JOIN editoras e ON e.id = s.editora_id
                WHERE lower(s.titulo) = lower('Saga do Batman, A 3ª Temporada')
                  AND lower(e.nome) = 'panini'
                  AND s.volume = 3
           )
       AND hqhub_normalizar_identidade(ed.numero) = '4'
       AND NOT EXISTS (
               SELECT 1
                 FROM edicoes existente
                WHERE existente.serie_id = serie_canonica_id
                  AND hqhub_normalizar_identidade(existente.numero) = '4'
           );
END $$;
