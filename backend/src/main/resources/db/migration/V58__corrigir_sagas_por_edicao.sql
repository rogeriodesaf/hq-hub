CREATE OR REPLACE FUNCTION hqhub_edicao_descreve_saga_volume(descricao TEXT, volume_alvo INTEGER)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN coalesce(descricao, '') ~* (volume_alvo::TEXT || '[^0-9]{0,10}s.{0,2}rie');
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION hqhub_mesclar_edicao_saga_por_edicao(descartada_id BIGINT, mantida_id BIGINT)
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

CREATE OR REPLACE FUNCTION hqhub_corrigir_saga_por_edicao(titulo_alvo TEXT, volume_alvo INTEGER, titulo_canonico TEXT)
RETURNS VOID AS $$
DECLARE
    serie_mantida_id BIGINT;
    edicao_alvo RECORD;
    edicao_mantida_id BIGINT;
    serie_vazia RECORD;
BEGIN
    SELECT s.id
      INTO serie_mantida_id
      FROM series s
      JOIN editoras e ON e.id = s.editora_id
      JOIN edicoes ed ON ed.serie_id = s.id
     WHERE hqhub_normalizar_titulo_serie(s.titulo) = hqhub_normalizar_titulo_serie(titulo_alvo)
       AND hqhub_normalizar_identidade(e.nome) = 'panini'
       AND hqhub_edicao_descreve_saga_volume(ed.descricao, volume_alvo)
     GROUP BY s.id, s.volume
     ORDER BY
       CASE WHEN s.volume = volume_alvo THEN 0 ELSE 1 END,
       count(ed.id) DESC,
       s.id
     LIMIT 1;

    IF serie_mantida_id IS NULL THEN
        RETURN;
    END IF;

    FOR edicao_alvo IN
        SELECT ed.id, ed.numero, ed.serie_id
          FROM edicoes ed
          JOIN series s ON s.id = ed.serie_id
          JOIN editoras e ON e.id = s.editora_id
         WHERE hqhub_normalizar_titulo_serie(s.titulo) = hqhub_normalizar_titulo_serie(titulo_alvo)
           AND hqhub_normalizar_identidade(e.nome) = 'panini'
           AND hqhub_edicao_descreve_saga_volume(ed.descricao, volume_alvo)
           AND ed.serie_id <> serie_mantida_id
         ORDER BY ed.id
    LOOP
        SELECT ed.id
          INTO edicao_mantida_id
          FROM edicoes ed
         WHERE ed.serie_id = serie_mantida_id
           AND hqhub_normalizar_identidade(ed.numero) = hqhub_normalizar_identidade(edicao_alvo.numero)
         ORDER BY ed.id
         LIMIT 1;

        IF edicao_mantida_id IS NULL THEN
            UPDATE edicoes
               SET serie_id = serie_mantida_id,
                   data_atualizacao = CURRENT_TIMESTAMP
             WHERE id = edicao_alvo.id;
        ELSE
            PERFORM hqhub_mesclar_edicao_saga_por_edicao(edicao_alvo.id, edicao_mantida_id);
        END IF;
    END LOOP;

    UPDATE series
       SET titulo = titulo_canonico,
           volume = volume_alvo,
           data_atualizacao = CURRENT_TIMESTAMP
     WHERE id = serie_mantida_id;

    FOR serie_vazia IN
        SELECT s.id
          FROM series s
          JOIN editoras e ON e.id = s.editora_id
         WHERE hqhub_normalizar_titulo_serie(s.titulo) = hqhub_normalizar_titulo_serie(titulo_alvo)
           AND hqhub_normalizar_identidade(e.nome) = 'panini'
           AND s.id <> serie_mantida_id
           AND NOT EXISTS (SELECT 1 FROM edicoes ed WHERE ed.serie_id = s.id)
         ORDER BY s.id
    LOOP
        DELETE FROM colecoes_series descartada
         USING colecoes_series mantida
         WHERE descartada.serie_id = serie_vazia.id
           AND mantida.serie_id = serie_mantida_id
           AND descartada.usuario_id = mantida.usuario_id;

        UPDATE colecoes_series
           SET serie_id = serie_mantida_id,
               data_atualizacao = CURRENT_TIMESTAMP
         WHERE serie_id = serie_vazia.id;

        DELETE FROM relacionamentos_series
         WHERE (serie_origem_id = serie_vazia.id AND serie_destino_id = serie_mantida_id)
            OR (serie_origem_id = serie_mantida_id AND serie_destino_id = serie_vazia.id);

        UPDATE relacionamentos_series SET serie_origem_id = serie_mantida_id WHERE serie_origem_id = serie_vazia.id;
        UPDATE relacionamentos_series SET serie_destino_id = serie_mantida_id WHERE serie_destino_id = serie_vazia.id;

        DELETE FROM series WHERE id = serie_vazia.id;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT hqhub_corrigir_saga_por_edicao('Saga do Homem-Aranha, A', 1, 'Saga do Homem-Aranha, A');
SELECT hqhub_corrigir_saga_por_edicao('Saga do Homem-Aranha, A', 2, 'Saga do Homem-Aranha, A');
SELECT hqhub_corrigir_saga_por_edicao('Saga do Batman, A', 1, 'Saga do Batman, A');
SELECT hqhub_corrigir_saga_por_edicao('Saga do Batman, A', 2, 'Saga do Batman, A');

DROP FUNCTION hqhub_corrigir_saga_por_edicao(TEXT, INTEGER, TEXT);
DROP FUNCTION hqhub_mesclar_edicao_saga_por_edicao(BIGINT, BIGINT);
DROP FUNCTION hqhub_edicao_descreve_saga_volume(TEXT, INTEGER);
