-- Conclui a correcao iniciada em V459: a serie atribuida a Panini e uma
-- duplicata da colecao A Teia do Aranha, da Abril. As edicoes, colecoes de
-- usuarios e demais referencias passam a apontar para a serie canonica Abril.
-- Nenhum dado de capa e alterado.
DO $$
DECLARE
    origem BIGINT;
    destino BIGINT;
    quantidade BIGINT;
BEGIN
    SELECT count(*), min(s.id) INTO quantidade, origem
      FROM series s
      JOIN editoras e ON e.id = s.editora_id
     WHERE hqhub_normalizar_titulo_serie(s.titulo) =
           hqhub_normalizar_titulo_serie('A Teia do Aranha')
       AND lower(trim(e.nome)) = 'panini';

    IF quantidade = 0 THEN
        RETURN; -- A duplicata ja foi removida ou nunca existiu neste banco.
    END IF;
    IF quantidade <> 1 THEN
        RAISE EXCEPTION 'Teia do Aranha: origem Panini ambigua (% series)', quantidade;
    END IF;

    SELECT count(*), min(s.id) INTO quantidade, destino
      FROM series s
      JOIN editoras e ON e.id = s.editora_id
     WHERE hqhub_normalizar_titulo_serie(s.titulo) =
           hqhub_normalizar_titulo_serie('A Teia do Aranha')
       AND lower(trim(e.nome)) = 'abril';

    IF quantidade <> 1 THEN
        RAISE EXCEPTION 'Teia do Aranha: esperado um destino Abril, encontrados %', quantidade;
    END IF;

    PERFORM id FROM series WHERE id IN (origem, destino) ORDER BY id FOR UPDATE;
    PERFORM id FROM edicoes WHERE serie_id IN (origem, destino) ORDER BY id FOR UPDATE;

    -- V459 normalmente ja esvaziou a origem. Estas validacoes tornam a
    -- consolidacao segura tambem caso tenham surgido novas edicoes depois dela.
    IF EXISTS (
        SELECT 1
          FROM edicoes
         WHERE serie_id = origem
           AND CASE WHEN trim(numero) ~ '^[0-9]+$'
                    THEN trim(numero)::numeric < 41
                    ELSE true
               END
    ) THEN
        RAISE EXCEPTION 'Teia do Aranha Panini contem numero inesperado; series nao foram unificadas';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM edicoes a
          JOIN edicoes b
            ON hqhub_normalizar_identidade(a.numero) =
               hqhub_normalizar_identidade(b.numero)
         WHERE a.serie_id = origem
           AND b.serie_id = destino
    ) THEN
        RAISE EXCEPTION 'Teia do Aranha: numero duplicado na Abril; series nao foram unificadas';
    END IF;

    UPDATE edicoes
       SET serie_id = destino,
           data_atualizacao = CURRENT_TIMESTAMP
     WHERE serie_id = origem;

    -- Um usuario pode ja ter as duas series na colecao. Nesse caso, mantem-se
    -- o registro da serie Abril e elimina-se apenas o vinculo redundante.
    DELETE FROM colecoes_series duplicada
     USING colecoes_series canonica
     WHERE duplicada.serie_id = origem
       AND canonica.serie_id = destino
       AND duplicada.usuario_id = canonica.usuario_id;

    UPDATE colecoes_series
       SET serie_id = destino,
           data_atualizacao = CURRENT_TIMESTAMP
     WHERE serie_id = origem;

    UPDATE postagens_feed
       SET serie_catalogo_id = destino
     WHERE serie_catalogo_id = origem;

    -- A ligacao direta entre as duas series viraria autorreferencia. Relacoes
    -- equivalentes ja existentes na serie Abril sao preservadas sem duplicar.
    DELETE FROM relacionamentos_series
     WHERE (serie_origem_id = origem AND serie_destino_id = destino)
        OR (serie_origem_id = destino AND serie_destino_id = origem);

    DELETE FROM relacionamentos_series duplicada
     USING relacionamentos_series canonica
     WHERE duplicada.serie_origem_id = origem
       AND canonica.serie_origem_id = destino
       AND duplicada.serie_destino_id = canonica.serie_destino_id
       AND duplicada.tipo = canonica.tipo;

    DELETE FROM relacionamentos_series duplicada
     USING relacionamentos_series canonica
     WHERE duplicada.serie_destino_id = origem
       AND canonica.serie_destino_id = destino
       AND duplicada.serie_origem_id = canonica.serie_origem_id
       AND duplicada.tipo = canonica.tipo;

    UPDATE relacionamentos_series
       SET serie_origem_id = destino,
           data_atualizacao = CURRENT_TIMESTAMP
     WHERE serie_origem_id = origem;

    UPDATE relacionamentos_series
       SET serie_destino_id = destino,
           data_atualizacao = CURRENT_TIMESTAMP
     WHERE serie_destino_id = origem;

    DELETE FROM series WHERE id = origem;

    RAISE NOTICE 'Teia do Aranha: serie Panini % unificada com a serie Abril %', origem, destino;
END $$;
