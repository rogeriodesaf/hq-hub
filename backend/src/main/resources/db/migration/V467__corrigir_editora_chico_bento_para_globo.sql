-- Corrige o cadastro informado pelo usuario: a serie Chico Bento foi vinculada
-- por engano a Panini, mas esta colecao pertence a Editora Globo.
-- A alteracao preserva a serie, suas edicoes, capas e todos os demais vinculos.
DO $$
DECLARE
    serie_chico_bento_id BIGINT;
    editora_globo_id BIGINT;
    quantidade BIGINT;
BEGIN
    SELECT count(*), min(s.id)
      INTO quantidade, serie_chico_bento_id
      FROM series s
      JOIN editoras e ON e.id = s.editora_id
     WHERE hqhub_normalizar_titulo_serie(s.titulo) =
           hqhub_normalizar_titulo_serie('Chico Bento')
       AND hqhub_normalizar_titulo_serie(e.nome) IN (
           hqhub_normalizar_titulo_serie('Panini'),
           hqhub_normalizar_titulo_serie('Panini Comics')
       );

    IF quantidade = 0 THEN
        RETURN; -- O cadastro incorreto nao existe ou ja foi corrigido.
    END IF;
    IF quantidade <> 1 THEN
        RAISE EXCEPTION
            'Chico Bento: esperado um cadastro na Panini, encontrados %',
            quantidade;
    END IF;

    SELECT count(*), min(e.id)
      INTO quantidade, editora_globo_id
      FROM editoras e
     WHERE hqhub_normalizar_titulo_serie(e.nome) IN (
           hqhub_normalizar_titulo_serie('Globo'),
           hqhub_normalizar_titulo_serie('Editora Globo')
       );

    IF quantidade <> 1 THEN
        RAISE EXCEPTION
            'Chico Bento: esperado um cadastro da editora Globo, encontrados %',
            quantidade;
    END IF;

    PERFORM id FROM series WHERE id = serie_chico_bento_id FOR UPDATE;

    -- Nao mescla automaticamente duas colecoes: se ja houver uma serie Globo
    -- com a mesma identidade editorial, a situacao exige conferencia manual.
    IF EXISTS (
        SELECT 1
          FROM series origem
          JOIN series destino
            ON destino.editora_id = editora_globo_id
           AND destino.id <> origem.id
           AND hqhub_normalizar_titulo_serie(destino.titulo) =
               hqhub_normalizar_titulo_serie(origem.titulo)
           AND COALESCE(destino.volume, 0) = COALESCE(origem.volume, 0)
         WHERE origem.id = serie_chico_bento_id
    ) THEN
        RAISE EXCEPTION
            'Chico Bento: ja existe serie Globo com o mesmo volume; nenhuma serie foi alterada';
    END IF;

    UPDATE series
       SET editora_id = editora_globo_id,
           data_atualizacao = CURRENT_TIMESTAMP
     WHERE id = serie_chico_bento_id;

    RAISE NOTICE
        'Chico Bento: serie % transferida da Panini para a editora Globo %',
        serie_chico_bento_id,
        editora_globo_id;
END $$;
