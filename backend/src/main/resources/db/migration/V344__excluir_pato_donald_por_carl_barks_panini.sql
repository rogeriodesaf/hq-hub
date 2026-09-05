-- Remove exclusivamente Pato Donald por Carl Barks, Panini V1, e seus vínculos.
DO $$
DECLARE
    ids_series BIGINT[];
    ids_edicoes BIGINT[];
    fk RECORD;
BEGIN
    SELECT array_agg(s.id) INTO ids_series
    FROM series s
    JOIN editoras e ON e.id = s.editora_id
    WHERE hqhub_normalizar_titulo_serie(s.titulo) =
          hqhub_normalizar_titulo_serie('Pato Donald por Carl Barks')
      AND lower(trim(e.nome)) LIKE 'panini%'
      AND coalesce(s.volume, 1) = 1;

    IF ids_series IS NULL THEN
        RETURN;
    END IF;

    SELECT array_agg(id) INTO ids_edicoes
    FROM edicoes
    WHERE serie_id = ANY(ids_series);

    IF ids_edicoes IS NOT NULL THEN
        FOR fk IN
            SELECT ns.nspname AS esquema, tabela.relname AS tabela, coluna.attname AS coluna
            FROM pg_constraint c
            JOIN pg_class tabela ON tabela.oid = c.conrelid
            JOIN pg_namespace ns ON ns.oid = tabela.relnamespace
            JOIN pg_attribute coluna ON coluna.attrelid = c.conrelid AND coluna.attnum = c.conkey[1]
            WHERE c.contype = 'f'
              AND c.confrelid = 'edicoes'::regclass
              AND ns.nspname = 'public'
        LOOP
            EXECUTE format('DELETE FROM %I.%I WHERE %I = ANY($1)', fk.esquema, fk.tabela, fk.coluna)
            USING ids_edicoes;
        END LOOP;

        DELETE FROM edicoes WHERE id = ANY(ids_edicoes);
    END IF;

    FOR fk IN
        SELECT ns.nspname AS esquema, tabela.relname AS tabela, coluna.attname AS coluna
        FROM pg_constraint c
        JOIN pg_class tabela ON tabela.oid = c.conrelid
        JOIN pg_namespace ns ON ns.oid = tabela.relnamespace
        JOIN pg_attribute coluna ON coluna.attrelid = c.conrelid AND coluna.attnum = c.conkey[1]
        WHERE c.contype = 'f'
          AND c.confrelid = 'series'::regclass
          AND c.conrelid <> 'edicoes'::regclass
          AND ns.nspname = 'public'
    LOOP
        EXECUTE format('DELETE FROM %I.%I WHERE %I = ANY($1)', fk.esquema, fk.tabela, fk.coluna)
        USING ids_series;
    END LOOP;

    DELETE FROM series WHERE id = ANY(ids_series);
END $$;
