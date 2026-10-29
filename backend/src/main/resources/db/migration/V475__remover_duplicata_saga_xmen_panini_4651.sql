-- Remove a coleção criada indevidamente pela importação da Panini e preserva
-- sua edição #16 na coleção canônica já existente:
--   Saga dos X-Men, A | Panini | V2
--
-- A origem é validada por ID, identidade editorial, SKU e URL oficial. A
-- migração interrompe o deploy se qualquer identidade estiver ambígua ou se a
-- edição #16 já existir no destino, evitando uma exclusão apenas plausível.

DO $$
DECLARE
    v_serie_origem_id CONSTANT BIGINT := 4651;
    v_serie_destino_id BIGINT;
    quantidade INTEGER;
BEGIN
    SELECT count(*)
      INTO quantidade
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE serie.id = v_serie_origem_id
       AND serie.titulo = 'A Saga Dos X-Men'
       AND serie.volume IS NULL
       AND hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Panini')
       AND serie.fonte_externa = 'PANINI'
       AND serie.id_externo = 'serie:asagadosxmen';

    IF quantidade = 0 THEN
        -- Permite reexecução segura caso o registro já tenha sido removido.
        RETURN;
    END IF;
    IF quantidade <> 1 THEN
        RAISE EXCEPTION 'Série 4651: identidade editorial inesperada ou ambígua';
    END IF;

    SELECT count(*), min(serie.id)
      INTO quantidade, v_serie_destino_id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE lower(trim(serie.titulo)) = lower('Saga dos X-Men, A')
       AND serie.volume = 2
       AND hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Panini');

    IF quantidade <> 1 THEN
        RAISE EXCEPTION
            'Saga dos X-Men, A/Panini/V2: esperado um destino único, encontrados %',
            quantidade;
    END IF;

    SELECT count(*)
      INTO quantidade
      FROM edicoes edicao
     WHERE edicao.serie_id = v_serie_origem_id
       AND hqhub_normalizar_identidade(edicao.numero) = '16'
       AND edicao.fonte_externa = 'PANINI'
       AND edicao.id_externo = 'ASAXM052'
       AND edicao.url_origem = 'https://panini.com.br/a-saga-dos-x-men-16-52';

    IF quantidade <> 1 OR
       (SELECT count(*) FROM edicoes WHERE serie_id = v_serie_origem_id) <> 1 THEN
        RAISE EXCEPTION
            'Série 4651: esperado somente A Saga dos X-Men #16 (ASAXM052)';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM edicoes
         WHERE serie_id = v_serie_destino_id
           AND hqhub_normalizar_identidade(numero) = '16'
    ) THEN
        RAISE EXCEPTION
            'Saga dos X-Men, A/Panini/V2 já possui a edição #16; mesclagem manual necessária';
    END IF;

    UPDATE edicoes
       SET serie_id = v_serie_destino_id,
           data_atualizacao = CURRENT_TIMESTAMP
     WHERE serie_id = v_serie_origem_id;

    DELETE FROM colecoes_series origem
     USING colecoes_series destino
     WHERE origem.serie_id = v_serie_origem_id
       AND destino.serie_id = v_serie_destino_id
       AND origem.usuario_id = destino.usuario_id;
    UPDATE colecoes_series
       SET serie_id = v_serie_destino_id,
           data_atualizacao = CURRENT_TIMESTAMP
     WHERE serie_id = v_serie_origem_id;

    UPDATE postagens_feed
       SET serie_catalogo_id = v_serie_destino_id
     WHERE serie_catalogo_id = v_serie_origem_id;

    DELETE FROM relacionamentos_series
     WHERE (serie_origem_id = v_serie_origem_id AND serie_destino_id = v_serie_destino_id)
        OR (serie_origem_id = v_serie_destino_id AND serie_destino_id = v_serie_origem_id);
    UPDATE relacionamentos_series
       SET serie_origem_id = v_serie_destino_id
     WHERE serie_origem_id = v_serie_origem_id;
    UPDATE relacionamentos_series
       SET serie_destino_id = v_serie_destino_id
     WHERE serie_destino_id = v_serie_origem_id;

    DELETE FROM relacionamentos_series duplicado
     USING relacionamentos_series mantido
     WHERE duplicado.id > mantido.id
       AND duplicado.serie_origem_id = mantido.serie_origem_id
       AND duplicado.serie_destino_id = mantido.serie_destino_id
       AND duplicado.tipo = mantido.tipo;

    DELETE FROM series WHERE id = v_serie_origem_id;
END
$$;
