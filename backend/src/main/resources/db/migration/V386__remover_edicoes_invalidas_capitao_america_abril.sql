-- Remove apenas os numeros espurios informados para Capitao America / Abril / V1.
-- O ID da serie e a identidade editorial impedem que a limpeza alcance homonimos.
DO $$
DECLARE
    ids_edicoes BIGINT[];
    fk RECORD;
BEGIN
    SELECT array_agg(ed.id) INTO ids_edicoes
    FROM edicoes ed
    JOIN series s ON s.id = ed.serie_id
    JOIN editoras p ON p.id = s.editora_id
    WHERE s.id = 2884
      AND COALESCE(s.volume, 1) = 1
      AND lower(trim(p.nome)) LIKE '%abril%'
      AND regexp_replace(trim(ed.numero), '^#?0*', '')
          IN ('319', '357', '368', '394', '435', '437', '445');

    IF ids_edicoes IS NULL THEN
        RETURN;
    END IF;

    -- Limpa todas as referencias atuais, inclusive tabelas adicionadas no futuro,
    -- antes de excluir as edicoes para nao violar chaves estrangeiras no deploy.
    FOR fk IN
        SELECT ns.nspname AS esquema, tabela.relname AS tabela, coluna.attname AS coluna
        FROM pg_constraint c
        JOIN pg_class tabela ON tabela.oid = c.conrelid
        JOIN pg_namespace ns ON ns.oid = tabela.relnamespace
        JOIN pg_attribute coluna
          ON coluna.attrelid = c.conrelid
         AND coluna.attnum = c.conkey[1]
        WHERE c.contype = 'f'
          AND c.confrelid = 'edicoes'::regclass
          AND ns.nspname = 'public'
    LOOP
        EXECUTE format(
            'DELETE FROM %I.%I WHERE %I = ANY($1)',
            fk.esquema,
            fk.tabela,
            fk.coluna
        ) USING ids_edicoes;
    END LOOP;

    DELETE FROM edicoes WHERE id = ANY(ids_edicoes);
END $$;
