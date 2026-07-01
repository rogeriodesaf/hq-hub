CREATE OR REPLACE FUNCTION hqhub_normalizar_identidade(valor TEXT)
RETURNS TEXT AS $$
    SELECT regexp_replace(
        lower(translate(coalesce(valor, ''),
            'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
            'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC')),
        '[^a-z0-9]+',
        '',
        'g');
$$ LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION hqhub_normalizar_titulo_serie(valor TEXT)
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

CREATE OR REPLACE FUNCTION hqhub_mesclar_edicao_catalogo(descartada_id BIGINT, mantida_id BIGINT)
RETURNS VOID AS $$
BEGIN
    UPDATE anuncios anuncio
       SET item_colecao_id = item_mantido.id
      FROM itens_colecao item_descartado
      JOIN itens_colecao item_mantido
        ON item_mantido.usuario_id = item_descartado.usuario_id
       AND item_mantido.edicao_id = mantida_id
     WHERE anuncio.item_colecao_id = item_descartado.id
       AND item_descartado.edicao_id = descartada_id;

    DELETE FROM itens_colecao item_descartado
     USING itens_colecao item_mantido
     WHERE item_descartado.edicao_id = descartada_id
       AND item_mantido.edicao_id = mantida_id
       AND item_descartado.usuario_id = item_mantido.usuario_id;

    UPDATE itens_colecao
       SET edicao_id = mantida_id,
           data_atualizacao = CURRENT_TIMESTAMP
     WHERE edicao_id = descartada_id;

    DELETE FROM compras_planejadas descartada
     USING compras_planejadas mantida
     WHERE descartada.edicao_id = descartada_id
       AND mantida.edicao_id = mantida_id
       AND descartada.usuario_id = mantida.usuario_id
       AND descartada.mes = mantida.mes
       AND descartada.ano = mantida.ano;

    UPDATE compras_planejadas
       SET edicao_id = mantida_id,
           data_atualizacao = CURRENT_TIMESTAMP
     WHERE edicao_id = descartada_id;

    DELETE FROM creditos_edicoes descartada
     USING creditos_edicoes mantida
     WHERE descartada.edicao_id = descartada_id
       AND mantida.edicao_id = mantida_id
       AND descartada.criador_id = mantida.criador_id
       AND descartada.papel = mantida.papel;

    UPDATE creditos_edicoes SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM links_edicoes descartada
     USING links_edicoes mantida
     WHERE descartada.edicao_id = descartada_id
       AND mantida.edicao_id = mantida_id
       AND descartada.url = mantida.url;

    UPDATE links_edicoes
       SET edicao_id = mantida_id,
           data_atualizacao = CURRENT_TIMESTAMP
     WHERE edicao_id = descartada_id;

    DELETE FROM conteudos_edicoes descartada
     USING conteudos_edicoes mantida
     WHERE descartada.edicao_id = descartada_id
       AND mantida.edicao_id = mantida_id
       AND descartada.ordem = mantida.ordem;

    UPDATE conteudos_edicoes SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM publicacoes_historias
     WHERE (edicao_original_id = descartada_id AND edicao_publicada_id = mantida_id)
        OR (edicao_original_id = mantida_id AND edicao_publicada_id = descartada_id);

    DELETE FROM publicacoes_historias descartada
     USING publicacoes_historias mantida
     WHERE descartada.edicao_publicada_id = descartada_id
       AND mantida.edicao_publicada_id = mantida_id
       AND descartada.historia_id = mantida.historia_id;

    UPDATE publicacoes_historias SET edicao_original_id = mantida_id WHERE edicao_original_id = descartada_id;
    UPDATE publicacoes_historias SET edicao_publicada_id = mantida_id WHERE edicao_publicada_id = descartada_id;

    DELETE FROM publicacoes_relacionadas
     WHERE (edicao_origem_id = descartada_id AND edicao_destino_id = mantida_id)
        OR (edicao_origem_id = mantida_id AND edicao_destino_id = descartada_id);

    DELETE FROM publicacoes_relacionadas descartada
     USING publicacoes_relacionadas mantida
     WHERE descartada.edicao_origem_id = descartada_id
       AND mantida.edicao_origem_id = mantida_id
       AND descartada.edicao_destino_id = mantida.edicao_destino_id
       AND descartada.tipo = mantida.tipo;

    UPDATE publicacoes_relacionadas SET edicao_origem_id = mantida_id WHERE edicao_origem_id = descartada_id;

    DELETE FROM publicacoes_relacionadas descartada
     USING publicacoes_relacionadas mantida
     WHERE descartada.edicao_destino_id = descartada_id
       AND mantida.edicao_destino_id = mantida_id
       AND descartada.edicao_origem_id = mantida.edicao_origem_id
       AND descartada.tipo = mantida.tipo;

    UPDATE publicacoes_relacionadas SET edicao_destino_id = mantida_id WHERE edicao_destino_id = descartada_id;

    UPDATE contribuicoes_catalogo SET edicao_id = mantida_id WHERE edicao_id = descartada_id;
    UPDATE contribuicoes_catalogo SET edicao_destino_id = mantida_id WHERE edicao_destino_id = descartada_id;
    UPDATE capas_edicao SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM edicoes WHERE id = descartada_id;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
    grupo RECORD;
    serie_mantida_id BIGINT;
    serie_descartada RECORD;
    edicao_descartada RECORD;
    edicao_mantida_id BIGINT;
BEGIN
    FOR grupo IN
        SELECT editora_id, coalesce(volume, 0) AS volume_chave, hqhub_normalizar_titulo_serie(titulo) AS titulo_chave
          FROM series
         GROUP BY editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo)
        HAVING count(*) > 1
    LOOP
        SELECT s.id
          INTO serie_mantida_id
          FROM series s
         WHERE s.editora_id = grupo.editora_id
           AND coalesce(s.volume, 0) = grupo.volume_chave
           AND hqhub_normalizar_titulo_serie(s.titulo) = grupo.titulo_chave
         ORDER BY
           (SELECT count(*) FROM edicoes ed WHERE ed.serie_id = s.id) DESC,
           CASE WHEN s.fonte_externa IS NOT NULL AND s.id_externo IS NOT NULL THEN 0 ELSE 1 END,
           s.id
         LIMIT 1;

        FOR serie_descartada IN
            SELECT s.id
              FROM series s
             WHERE s.editora_id = grupo.editora_id
               AND coalesce(s.volume, 0) = grupo.volume_chave
               AND hqhub_normalizar_titulo_serie(s.titulo) = grupo.titulo_chave
               AND s.id <> serie_mantida_id
             ORDER BY s.id
        LOOP
            FOR edicao_descartada IN
                SELECT ed.id, ed.numero
                  FROM edicoes ed
                 WHERE ed.serie_id = serie_descartada.id
                 ORDER BY ed.id
            LOOP
                SELECT ed.id
                  INTO edicao_mantida_id
                  FROM edicoes ed
                 WHERE ed.serie_id = serie_mantida_id
                   AND hqhub_normalizar_identidade(ed.numero) = hqhub_normalizar_identidade(edicao_descartada.numero)
                 ORDER BY ed.id
                 LIMIT 1;

                IF edicao_mantida_id IS NULL THEN
                    UPDATE edicoes
                       SET serie_id = serie_mantida_id,
                           data_atualizacao = CURRENT_TIMESTAMP
                     WHERE id = edicao_descartada.id;
                ELSE
                    PERFORM hqhub_mesclar_edicao_catalogo(edicao_descartada.id, edicao_mantida_id);
                END IF;
            END LOOP;

            DELETE FROM colecoes_series descartada
             USING colecoes_series mantida
             WHERE descartada.serie_id = serie_descartada.id
               AND mantida.serie_id = serie_mantida_id
               AND descartada.usuario_id = mantida.usuario_id;

            UPDATE colecoes_series
               SET serie_id = serie_mantida_id,
                   data_atualizacao = CURRENT_TIMESTAMP
             WHERE serie_id = serie_descartada.id;

            DELETE FROM relacionamentos_series
             WHERE (serie_origem_id = serie_descartada.id AND serie_destino_id = serie_mantida_id)
                OR (serie_origem_id = serie_mantida_id AND serie_destino_id = serie_descartada.id);

            UPDATE relacionamentos_series SET serie_origem_id = serie_mantida_id WHERE serie_origem_id = serie_descartada.id;
            UPDATE relacionamentos_series SET serie_destino_id = serie_mantida_id WHERE serie_destino_id = serie_descartada.id;

            DELETE FROM relacionamentos_series duplicado
             USING relacionamentos_series mantido
             WHERE duplicado.id > mantido.id
               AND duplicado.serie_origem_id = mantido.serie_origem_id
               AND duplicado.serie_destino_id = mantido.serie_destino_id
               AND duplicado.tipo = mantido.tipo;

            DELETE FROM series WHERE id = serie_descartada.id;
        END LOOP;
    END LOOP;

    FOR grupo IN
        SELECT serie_id, hqhub_normalizar_identidade(numero) AS numero_chave
          FROM edicoes
         GROUP BY serie_id, hqhub_normalizar_identidade(numero)
        HAVING count(*) > 1
    LOOP
        SELECT ed.id
          INTO edicao_mantida_id
          FROM edicoes ed
         WHERE ed.serie_id = grupo.serie_id
           AND hqhub_normalizar_identidade(ed.numero) = grupo.numero_chave
         ORDER BY
           CASE WHEN ed.url_capa IS NOT NULL AND ed.url_capa <> '' THEN 0 ELSE 1 END,
           CASE WHEN ed.fonte_externa IS NOT NULL AND ed.id_externo IS NOT NULL THEN 0 ELSE 1 END,
           ed.id
         LIMIT 1;

        FOR edicao_descartada IN
            SELECT ed.id
              FROM edicoes ed
             WHERE ed.serie_id = grupo.serie_id
               AND hqhub_normalizar_identidade(ed.numero) = grupo.numero_chave
               AND ed.id <> edicao_mantida_id
             ORDER BY ed.id
        LOOP
            PERFORM hqhub_mesclar_edicao_catalogo(edicao_descartada.id, edicao_mantida_id);
        END LOOP;
    END LOOP;
END $$;

DROP INDEX IF EXISTS uk_series_titulo_editora_volume;
CREATE UNIQUE INDEX IF NOT EXISTS uk_series_identidade_editora_volume
ON series (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo));

ALTER TABLE edicoes DROP CONSTRAINT IF EXISTS uk_edicoes_numero_serie;
CREATE UNIQUE INDEX IF NOT EXISTS uk_edicoes_identidade_numero_serie
ON edicoes (serie_id, hqhub_normalizar_identidade(numero));

DROP FUNCTION hqhub_mesclar_edicao_catalogo(BIGINT, BIGINT);
