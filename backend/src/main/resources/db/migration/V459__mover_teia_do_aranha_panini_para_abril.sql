-- Corrige o cadastro indicado pelo usuario: A Teia do Aranha #41 em diante
-- pertence a Abril. Preserva os IDs e todos os vinculos das edicoes.
-- Nao altera as edicoes preexistentes nem remove a serie de origem.
DO $$
DECLARE
    origem BIGINT;
    destino BIGINT;
    quantidade BIGINT;
BEGIN
    SELECT count(*), min(s.id) INTO quantidade, origem
      FROM series s JOIN editoras p ON p.id = s.editora_id
     WHERE hqhub_normalizar_titulo_serie(s.titulo) = hqhub_normalizar_titulo_serie('A Teia do Aranha')
       AND lower(trim(p.nome)) = 'panini';
    IF quantidade = 0 THEN
        RETURN; -- Banco sem o cadastro incorreto.
    END IF;
    IF quantidade <> 1 THEN
        RAISE EXCEPTION 'Teia do Aranha: origem Panini ambigua (% series)', quantidade;
    END IF;

    SELECT count(*), min(s.id) INTO quantidade, destino
      FROM series s JOIN editoras p ON p.id = s.editora_id
     WHERE hqhub_normalizar_titulo_serie(s.titulo) = hqhub_normalizar_titulo_serie('A Teia do Aranha')
       AND lower(trim(p.nome)) = 'abril';
    IF quantidade <> 1 THEN
        RAISE EXCEPTION 'Teia do Aranha: esperado um destino Abril, encontrados %', quantidade;
    END IF;

    PERFORM id FROM series WHERE id IN (origem, destino) ORDER BY id FOR UPDATE;
    PERFORM id FROM edicoes WHERE serie_id IN (origem, destino) ORDER BY id FOR UPDATE;

    -- Rejeita numeracao inesperada em vez de mover outra colecao por engano.
    IF EXISTS (
        SELECT 1 FROM edicoes WHERE serie_id = origem
          AND CASE WHEN trim(numero) ~ '^[0-9]+$'
                   THEN trim(numero)::numeric < 41 ELSE true END
    ) THEN
        RAISE EXCEPTION 'Teia do Aranha Panini contem numero inesperado; nenhuma edicao foi movida';
    END IF;
    IF EXISTS (
        SELECT 1 FROM edicoes a JOIN edicoes b
          ON hqhub_normalizar_identidade(a.numero) = hqhub_normalizar_identidade(b.numero)
         WHERE a.serie_id = origem AND b.serie_id = destino
    ) THEN
        RAISE EXCEPTION 'Teia do Aranha: numero ja existente na Abril; nenhuma edicao foi sobrescrita';
    END IF;

    UPDATE edicoes SET serie_id = destino, data_atualizacao = CURRENT_TIMESTAMP
     WHERE serie_id = origem;
    GET DIAGNOSTICS quantidade = ROW_COUNT;
    RAISE NOTICE 'Teia do Aranha: % edicoes transferidas da serie % para %', quantidade, origem, destino;
END $$;
