CREATE OR REPLACE FUNCTION hqhub_normalizar_titulo_identidade(valor TEXT)
RETURNS TEXT AS $$
DECLARE
    termos TEXT[];
BEGIN
    termos := regexp_split_to_array(
        regexp_replace(
            lower(translate(coalesce(valor, ''),
                'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
                'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC')),
            '[^a-z0-9]+',
            ' ',
            'g'),
        '\s+');

    termos := array_remove(termos, '');

    WHILE array_length(termos, 1) > 0 AND termos[1] = ANY (ARRAY['a', 'as', 'o', 'os']) LOOP
        termos := termos[2:array_length(termos, 1)];
    END LOOP;

    WHILE array_length(termos, 1) > 0 AND termos[array_length(termos, 1)] = ANY (ARRAY['a', 'as', 'o', 'os']) LOOP
        termos := termos[1:array_length(termos, 1) - 1];
    END LOOP;

    RETURN array_to_string(termos, '');
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION hqhub_mesclar_edicao(descartada_id BIGINT, canonica_id BIGINT)
RETURNS VOID AS $$
BEGIN
    UPDATE anuncios anuncio
       SET item_colecao_id = item_mantido.id
      FROM itens_colecao item_descartado
      JOIN itens_colecao item_mantido
        ON item_mantido.usuario_id = item_descartado.usuario_id
       AND item_mantido.edicao_id = canonica_id
     WHERE anuncio.item_colecao_id = item_descartado.id
       AND item_descartado.edicao_id = descartada_id;

    DELETE FROM itens_colecao item_descartado
     USING itens_colecao item_mantido
     WHERE item_descartado.edicao_id = descartada_id
       AND item_mantido.edicao_id = canonica_id
       AND item_descartado.usuario_id = item_mantido.usuario_id;

    UPDATE itens_colecao
       SET edicao_id = canonica_id,
           data_atualizacao = CURRENT_TIMESTAMP
     WHERE edicao_id = descartada_id;

    DELETE FROM compras_planejadas descartada
     USING compras_planejadas mantida
     WHERE descartada.edicao_id = descartada_id
       AND mantida.edicao_id = canonica_id
       AND descartada.usuario_id = mantida.usuario_id
       AND descartada.mes = mantida.mes
       AND descartada.ano = mantida.ano;

    UPDATE compras_planejadas
       SET edicao_id = canonica_id,
           data_atualizacao = CURRENT_TIMESTAMP
     WHERE edicao_id = descartada_id;

    DELETE FROM creditos_edicoes descartada
     USING creditos_edicoes mantida
     WHERE descartada.edicao_id = descartada_id
       AND mantida.edicao_id = canonica_id
       AND descartada.criador_id = mantida.criador_id
       AND descartada.papel = mantida.papel;

    UPDATE creditos_edicoes
       SET edicao_id = canonica_id
     WHERE edicao_id = descartada_id;

    DELETE FROM links_edicoes descartada
     USING links_edicoes mantida
     WHERE descartada.edicao_id = descartada_id
       AND mantida.edicao_id = canonica_id
       AND descartada.url = mantida.url;

    UPDATE links_edicoes
       SET edicao_id = canonica_id,
           data_atualizacao = CURRENT_TIMESTAMP
     WHERE edicao_id = descartada_id;

    DELETE FROM conteudos_edicoes descartada
     USING conteudos_edicoes mantida
     WHERE descartada.edicao_id = descartada_id
       AND mantida.edicao_id = canonica_id
       AND descartada.ordem = mantida.ordem;

    UPDATE conteudos_edicoes
       SET edicao_id = canonica_id
     WHERE edicao_id = descartada_id;

    DELETE FROM publicacoes_historias
     WHERE (edicao_original_id = descartada_id AND edicao_publicada_id = canonica_id)
        OR (edicao_original_id = canonica_id AND edicao_publicada_id = descartada_id);

    DELETE FROM publicacoes_historias descartada
     USING publicacoes_historias mantida
     WHERE descartada.edicao_publicada_id = descartada_id
       AND mantida.edicao_publicada_id = canonica_id
       AND descartada.historia_id = mantida.historia_id;

    UPDATE publicacoes_historias
       SET edicao_original_id = canonica_id
     WHERE edicao_original_id = descartada_id;

    UPDATE publicacoes_historias
       SET edicao_publicada_id = canonica_id
     WHERE edicao_publicada_id = descartada_id;

    DELETE FROM publicacoes_relacionadas
     WHERE (edicao_origem_id = descartada_id AND edicao_destino_id = canonica_id)
        OR (edicao_origem_id = canonica_id AND edicao_destino_id = descartada_id);

    DELETE FROM publicacoes_relacionadas descartada
     USING publicacoes_relacionadas mantida
     WHERE descartada.edicao_origem_id = descartada_id
       AND mantida.edicao_origem_id = canonica_id
       AND descartada.edicao_destino_id = mantida.edicao_destino_id
       AND descartada.tipo = mantida.tipo;

    UPDATE publicacoes_relacionadas
       SET edicao_origem_id = canonica_id
     WHERE edicao_origem_id = descartada_id;

    DELETE FROM publicacoes_relacionadas descartada
     USING publicacoes_relacionadas mantida
     WHERE descartada.edicao_destino_id = descartada_id
       AND mantida.edicao_destino_id = canonica_id
       AND descartada.edicao_origem_id = mantida.edicao_origem_id
       AND descartada.tipo = mantida.tipo;

    UPDATE publicacoes_relacionadas
       SET edicao_destino_id = canonica_id
     WHERE edicao_destino_id = descartada_id;

    UPDATE contribuicoes_catalogo
       SET edicao_id = canonica_id
     WHERE edicao_id = descartada_id;

    UPDATE contribuicoes_catalogo
       SET edicao_destino_id = canonica_id
     WHERE edicao_destino_id = descartada_id;

    UPDATE capas_edicao
       SET edicao_id = canonica_id
     WHERE edicao_id = descartada_id;

    DELETE FROM edicoes WHERE id = descartada_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION hqhub_unificar_serie(titulo_alvo TEXT, volume_alvo INTEGER, titulo_canonico TEXT)
RETURNS VOID AS $$
DECLARE
    serie_canonica_id BIGINT;
    serie_descartada RECORD;
    edicao_descartada RECORD;
    edicao_canonica_id BIGINT;
BEGIN
    SELECT s.id
      INTO serie_canonica_id
      FROM series s
      JOIN editoras e ON e.id = s.editora_id
     WHERE hqhub_normalizar_titulo_identidade(s.titulo) = hqhub_normalizar_titulo_identidade(titulo_alvo)
       AND hqhub_normalizar_titulo_identidade(e.nome) = 'panini'
       AND (
            s.volume = volume_alvo
            OR (
                s.volume IS NULL
                AND EXISTS (
                    SELECT 1
                      FROM edicoes ed
                     WHERE ed.serie_id = s.id
                       AND (
                            hqhub_normalizar_titulo_identidade(ed.descricao) LIKE ('%' || volume_alvo || 'serie%')
                            OR hqhub_normalizar_titulo_identidade(ed.descricao) LIKE ('%' || volume_alvo || 'aserie%')
                       )
                )
            )
       )
     ORDER BY
       CASE WHEN s.titulo = titulo_canonico THEN 0 ELSE 1 END,
       CASE WHEN s.volume = volume_alvo THEN 0 ELSE 1 END,
       (SELECT count(*) FROM edicoes ed WHERE ed.serie_id = s.id) DESC,
       s.id
     LIMIT 1;

    IF serie_canonica_id IS NULL THEN
        RETURN;
    END IF;

    UPDATE series
       SET volume = volume_alvo,
           data_atualizacao = CURRENT_TIMESTAMP
     WHERE id = serie_canonica_id;

    FOR serie_descartada IN
        SELECT s.id
          FROM series s
          JOIN editoras e ON e.id = s.editora_id
         WHERE hqhub_normalizar_titulo_identidade(s.titulo) = hqhub_normalizar_titulo_identidade(titulo_alvo)
           AND hqhub_normalizar_titulo_identidade(e.nome) = 'panini'
           AND s.id <> serie_canonica_id
           AND (
                s.volume = volume_alvo
                OR (
                    s.volume IS NULL
                    AND EXISTS (
                        SELECT 1
                          FROM edicoes ed
                         WHERE ed.serie_id = s.id
                           AND (
                                hqhub_normalizar_titulo_identidade(ed.descricao) LIKE ('%' || volume_alvo || 'serie%')
                                OR hqhub_normalizar_titulo_identidade(ed.descricao) LIKE ('%' || volume_alvo || 'aserie%')
                           )
                    )
                )
           )
         ORDER BY s.id
    LOOP
        FOR edicao_descartada IN
            SELECT ed.id, ed.numero
              FROM edicoes ed
             WHERE ed.serie_id = serie_descartada.id
             ORDER BY ed.id
        LOOP
            SELECT ed.id
              INTO edicao_canonica_id
              FROM edicoes ed
             WHERE ed.serie_id = serie_canonica_id
               AND lower(ed.numero) = lower(edicao_descartada.numero)
             ORDER BY ed.id
             LIMIT 1;

            IF edicao_canonica_id IS NULL THEN
                UPDATE edicoes
                   SET serie_id = serie_canonica_id,
                       data_atualizacao = CURRENT_TIMESTAMP
                 WHERE id = edicao_descartada.id;
            ELSE
                PERFORM hqhub_mesclar_edicao(edicao_descartada.id, edicao_canonica_id);
            END IF;
        END LOOP;

        DELETE FROM colecoes_series descartada
         USING colecoes_series mantida
         WHERE descartada.serie_id = serie_descartada.id
           AND mantida.serie_id = serie_canonica_id
           AND descartada.usuario_id = mantida.usuario_id;

        UPDATE colecoes_series
           SET serie_id = serie_canonica_id,
               data_atualizacao = CURRENT_TIMESTAMP
         WHERE serie_id = serie_descartada.id;

        DELETE FROM relacionamentos_series
         WHERE serie_origem_id = serie_descartada.id
           AND serie_destino_id = serie_canonica_id;

        DELETE FROM relacionamentos_series
         WHERE serie_origem_id = serie_canonica_id
           AND serie_destino_id = serie_descartada.id;

        UPDATE relacionamentos_series
           SET serie_origem_id = serie_canonica_id
         WHERE serie_origem_id = serie_descartada.id;

        UPDATE relacionamentos_series
           SET serie_destino_id = serie_canonica_id
         WHERE serie_destino_id = serie_descartada.id;

        DELETE FROM relacionamentos_series duplicado
         USING relacionamentos_series mantido
         WHERE duplicado.id > mantido.id
           AND duplicado.serie_origem_id = mantido.serie_origem_id
           AND duplicado.serie_destino_id = mantido.serie_destino_id
           AND duplicado.tipo = mantido.tipo;

        DELETE FROM series WHERE id = serie_descartada.id;
    END LOOP;

    UPDATE series
       SET titulo = titulo_canonico,
           volume = volume_alvo,
           data_atualizacao = CURRENT_TIMESTAMP
     WHERE id = serie_canonica_id;
END;
$$ LANGUAGE plpgsql;

SELECT hqhub_unificar_serie('Saga do Homem-Aranha, A', 1, 'Saga do Homem-Aranha, A');
SELECT hqhub_unificar_serie('A Saga do Homem-Aranha', 1, 'Saga do Homem-Aranha, A');
SELECT hqhub_unificar_serie('Saga do Batman, A', 2, 'Saga do Batman, A');
SELECT hqhub_unificar_serie('A Saga do Batman', 2, 'Saga do Batman, A');

DROP FUNCTION hqhub_unificar_serie(TEXT, INTEGER, TEXT);
DROP FUNCTION hqhub_mesclar_edicao(BIGINT, BIGINT);
DROP FUNCTION hqhub_normalizar_titulo_identidade(TEXT);
