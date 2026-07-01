CREATE OR REPLACE FUNCTION hqhub_normalizar_titulo(valor TEXT)
RETURNS TEXT AS $$
    SELECT regexp_replace(
        lower(translate(coalesce(valor, ''),
            'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
            'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC')),
        '[^a-z0-9]+',
        '',
        'g');
$$ LANGUAGE SQL IMMUTABLE;

DO $$
DECLARE
    alvo RECORD;
    serie_canonica_id BIGINT;
    serie_descartada RECORD;
    edicao_descartada RECORD;
    edicao_canonica_id BIGINT;
BEGIN
    FOR alvo IN
        SELECT *
          FROM (VALUES
              ('bibliotecamauriciodesousamonica', 'Biblioteca Mauricio de Sousa: Mônica'),
              ('bibliotecamauriciodesousacebolinha', 'Biblioteca Mauricio de Sousa: Cebolinha')
          ) AS t(titulo_normalizado, titulo_canonico)
    LOOP
        SELECT s.id
          INTO serie_canonica_id
          FROM series s
          JOIN editoras e ON e.id = s.editora_id
         WHERE hqhub_normalizar_titulo(s.titulo) = alvo.titulo_normalizado
           AND hqhub_normalizar_titulo(e.nome) = 'panini'
         ORDER BY
           CASE WHEN coalesce(s.volume, 1) = 1 THEN 0 ELSE 1 END,
           s.id
         LIMIT 1;

        IF serie_canonica_id IS NULL THEN
            CONTINUE;
        END IF;

        UPDATE series
           SET volume = 1,
               data_atualizacao = CURRENT_TIMESTAMP
         WHERE id = serie_canonica_id;

        FOR serie_descartada IN
            SELECT s.id
              FROM series s
              JOIN editoras e ON e.id = s.editora_id
             WHERE hqhub_normalizar_titulo(s.titulo) = alvo.titulo_normalizado
               AND hqhub_normalizar_titulo(e.nome) = 'panini'
               AND s.id <> serie_canonica_id
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
                    UPDATE anuncios anuncio
                       SET item_colecao_id = item_mantido.id
                      FROM itens_colecao item_descartado
                      JOIN itens_colecao item_mantido
                        ON item_mantido.usuario_id = item_descartado.usuario_id
                       AND item_mantido.edicao_id = edicao_canonica_id
                     WHERE anuncio.item_colecao_id = item_descartado.id
                       AND item_descartado.edicao_id = edicao_descartada.id;

                    DELETE FROM itens_colecao item_descartado
                     USING itens_colecao item_mantido
                     WHERE item_descartado.edicao_id = edicao_descartada.id
                       AND item_mantido.edicao_id = edicao_canonica_id
                       AND item_descartado.usuario_id = item_mantido.usuario_id;

                    UPDATE itens_colecao
                       SET edicao_id = edicao_canonica_id,
                           data_atualizacao = CURRENT_TIMESTAMP
                     WHERE edicao_id = edicao_descartada.id;

                    DELETE FROM compras_planejadas descartada
                     USING compras_planejadas mantida
                     WHERE descartada.edicao_id = edicao_descartada.id
                       AND mantida.edicao_id = edicao_canonica_id
                       AND descartada.usuario_id = mantida.usuario_id
                       AND descartada.mes = mantida.mes
                       AND descartada.ano = mantida.ano;

                    UPDATE compras_planejadas
                       SET edicao_id = edicao_canonica_id,
                           data_atualizacao = CURRENT_TIMESTAMP
                     WHERE edicao_id = edicao_descartada.id;

                    DELETE FROM creditos_edicoes descartada
                     USING creditos_edicoes mantida
                     WHERE descartada.edicao_id = edicao_descartada.id
                       AND mantida.edicao_id = edicao_canonica_id
                       AND descartada.criador_id = mantida.criador_id
                       AND descartada.papel = mantida.papel;

                    UPDATE creditos_edicoes
                       SET edicao_id = edicao_canonica_id
                     WHERE edicao_id = edicao_descartada.id;

                    DELETE FROM links_edicoes descartada
                     USING links_edicoes mantida
                     WHERE descartada.edicao_id = edicao_descartada.id
                       AND mantida.edicao_id = edicao_canonica_id
                       AND descartada.url = mantida.url;

                    UPDATE links_edicoes
                       SET edicao_id = edicao_canonica_id,
                           data_atualizacao = CURRENT_TIMESTAMP
                     WHERE edicao_id = edicao_descartada.id;

                    DELETE FROM conteudos_edicoes descartada
                     USING conteudos_edicoes mantida
                     WHERE descartada.edicao_id = edicao_descartada.id
                       AND mantida.edicao_id = edicao_canonica_id
                       AND descartada.ordem = mantida.ordem;

                    UPDATE conteudos_edicoes
                       SET edicao_id = edicao_canonica_id
                     WHERE edicao_id = edicao_descartada.id;

                    DELETE FROM publicacoes_historias
                     WHERE (edicao_original_id = edicao_descartada.id AND edicao_publicada_id = edicao_canonica_id)
                        OR (edicao_original_id = edicao_canonica_id AND edicao_publicada_id = edicao_descartada.id);

                    DELETE FROM publicacoes_historias descartada
                     USING publicacoes_historias mantida
                     WHERE descartada.edicao_publicada_id = edicao_descartada.id
                       AND mantida.edicao_publicada_id = edicao_canonica_id
                       AND descartada.historia_id = mantida.historia_id;

                    UPDATE publicacoes_historias
                       SET edicao_original_id = edicao_canonica_id
                     WHERE edicao_original_id = edicao_descartada.id;

                    UPDATE publicacoes_historias
                       SET edicao_publicada_id = edicao_canonica_id
                     WHERE edicao_publicada_id = edicao_descartada.id;

                    DELETE FROM publicacoes_relacionadas
                     WHERE (edicao_origem_id = edicao_descartada.id AND edicao_destino_id = edicao_canonica_id)
                        OR (edicao_origem_id = edicao_canonica_id AND edicao_destino_id = edicao_descartada.id);

                    DELETE FROM publicacoes_relacionadas descartada
                     USING publicacoes_relacionadas mantida
                     WHERE descartada.edicao_origem_id = edicao_descartada.id
                       AND mantida.edicao_origem_id = edicao_canonica_id
                       AND descartada.edicao_destino_id = mantida.edicao_destino_id
                       AND descartada.tipo = mantida.tipo;

                    UPDATE publicacoes_relacionadas
                       SET edicao_origem_id = edicao_canonica_id
                     WHERE edicao_origem_id = edicao_descartada.id;

                    DELETE FROM publicacoes_relacionadas descartada
                     USING publicacoes_relacionadas mantida
                     WHERE descartada.edicao_destino_id = edicao_descartada.id
                       AND mantida.edicao_destino_id = edicao_canonica_id
                       AND descartada.edicao_origem_id = mantida.edicao_origem_id
                       AND descartada.tipo = mantida.tipo;

                    UPDATE publicacoes_relacionadas
                       SET edicao_destino_id = edicao_canonica_id
                     WHERE edicao_destino_id = edicao_descartada.id;

                    UPDATE contribuicoes_catalogo
                       SET edicao_id = edicao_canonica_id
                     WHERE edicao_id = edicao_descartada.id;

                    UPDATE contribuicoes_catalogo
                       SET edicao_destino_id = edicao_canonica_id
                     WHERE edicao_destino_id = edicao_descartada.id;

                    UPDATE capas_edicao
                       SET edicao_id = edicao_canonica_id
                     WHERE edicao_id = edicao_descartada.id;

                    DELETE FROM edicoes WHERE id = edicao_descartada.id;
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
           SET titulo = alvo.titulo_canonico,
               volume = 1,
               data_atualizacao = CURRENT_TIMESTAMP
         WHERE id = serie_canonica_id;
    END LOOP;
END $$;

DROP FUNCTION hqhub_normalizar_titulo(TEXT);
