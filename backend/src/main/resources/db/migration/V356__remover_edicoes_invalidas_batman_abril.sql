-- Remove os cinco numeros espurios confirmados na serie 2611 e a serie vazia
-- 1022. Os IDs e as identidades editoriais evitam atingir outros cadastros.
DO $$
DECLARE
    ids_edicoes BIGINT[];
    ids_series BIGINT[];
    fk RECORD;
BEGIN
    SELECT array_agg(ed.id) INTO ids_edicoes
    FROM edicoes ed
    JOIN series s ON s.id = ed.serie_id
    JOIN editoras e ON e.id = s.editora_id
    WHERE s.id = 2611
      AND hqhub_normalizar_titulo_serie(s.titulo)
          = hqhub_normalizar_titulo_serie('Batman 1ª Série')
      AND hqhub_normalizar_titulo_serie(e.nome) LIKE '%abril%'
      AND ed.numero IN ('98', '106', '232', '241', '309');

    IF ids_edicoes IS NOT NULL THEN
        FOR fk IN
            SELECT ns.nspname AS esquema, tabela.relname AS tabela, coluna.attname AS coluna
            FROM pg_constraint c
            JOIN pg_class tabela ON tabela.oid = c.conrelid
            JOIN pg_namespace ns ON ns.oid = tabela.relnamespace
            JOIN pg_attribute coluna
              ON coluna.attrelid = c.conrelid AND coluna.attnum = c.conkey[1]
            WHERE c.contype = 'f'
              AND c.confrelid = 'edicoes'::regclass
              AND ns.nspname = 'public'
        LOOP
            EXECUTE format('DELETE FROM %I.%I WHERE %I = ANY($1)',
                           fk.esquema, fk.tabela, fk.coluna)
            USING ids_edicoes;
        END LOOP;

        DELETE FROM edicoes WHERE id = ANY(ids_edicoes);
    END IF;

    SELECT array_agg(s.id) INTO ids_series
    FROM series s
    JOIN editoras e ON e.id = s.editora_id
    WHERE s.id = 1022
      AND hqhub_normalizar_titulo_serie(s.titulo)
          = hqhub_normalizar_titulo_serie('Batman')
      AND hqhub_normalizar_titulo_serie(e.nome) LIKE '%abril%'
      AND coalesce(s.volume, 1) = 1
      AND NOT EXISTS (SELECT 1 FROM edicoes ed WHERE ed.serie_id = s.id);

    IF ids_series IS NOT NULL THEN
        FOR fk IN
            SELECT ns.nspname AS esquema, tabela.relname AS tabela, coluna.attname AS coluna
            FROM pg_constraint c
            JOIN pg_class tabela ON tabela.oid = c.conrelid
            JOIN pg_namespace ns ON ns.oid = tabela.relnamespace
            JOIN pg_attribute coluna
              ON coluna.attrelid = c.conrelid AND coluna.attnum = c.conkey[1]
            WHERE c.contype = 'f'
              AND c.confrelid = 'series'::regclass
              AND c.conrelid <> 'edicoes'::regclass
              AND ns.nspname = 'public'
        LOOP
            EXECUTE format('DELETE FROM %I.%I WHERE %I = ANY($1)',
                           fk.esquema, fk.tabela, fk.coluna)
            USING ids_series;
        END LOOP;

        DELETE FROM series WHERE id = ANY(ids_series);
    END IF;
END $$;
