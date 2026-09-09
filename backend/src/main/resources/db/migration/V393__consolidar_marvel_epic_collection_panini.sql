-- Consolida os cadastros incorretos na serie canonica Marvel Epic Collection, Panini V1.
CREATE OR REPLACE FUNCTION hqhub_mesclar_edicao_epic_collection(descartada_id BIGINT, mantida_id BIGINT)
RETURNS VOID AS $$
BEGIN
    -- Aproveita dados editoriais da edicao incorreta quando faltarem na canonica.
    UPDATE edicoes mantida
       SET titulo = coalesce(mantida.titulo, descartada.titulo),
           descricao = coalesce(mantida.descricao, descartada.descricao),
           data_publicacao = coalesce(mantida.data_publicacao, descartada.data_publicacao),
           url_capa = coalesce(nullif(trim(mantida.url_capa), ''), descartada.url_capa),
           codigo_barras = coalesce(mantida.codigo_barras, descartada.codigo_barras),
           quantidade_paginas = coalesce(mantida.quantidade_paginas, descartada.quantidade_paginas),
           preco_capa = coalesce(mantida.preco_capa, descartada.preco_capa),
           formato = coalesce(mantida.formato, descartada.formato),
           data_atualizacao = CURRENT_TIMESTAMP
      FROM edicoes descartada
     WHERE mantida.id = mantida_id AND descartada.id = descartada_id;

    UPDATE anuncios anuncio SET item_colecao_id = item_mantido.id
      FROM itens_colecao item_descartado
      JOIN itens_colecao item_mantido
        ON item_mantido.usuario_id = item_descartado.usuario_id
       AND item_mantido.edicao_id = mantida_id
     WHERE anuncio.item_colecao_id = item_descartado.id
       AND item_descartado.edicao_id = descartada_id;

    DELETE FROM itens_colecao descartado USING itens_colecao mantido
     WHERE descartado.edicao_id = descartada_id AND mantido.edicao_id = mantida_id
       AND descartado.usuario_id = mantido.usuario_id;
    UPDATE itens_colecao SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM compras_planejadas descartada USING compras_planejadas mantida
     WHERE descartada.edicao_id = descartada_id AND mantida.edicao_id = mantida_id
       AND descartada.usuario_id = mantida.usuario_id
       AND descartada.mes = mantida.mes AND descartada.ano = mantida.ano;
    UPDATE compras_planejadas SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM creditos_edicoes descartada USING creditos_edicoes mantida
     WHERE descartada.edicao_id = descartada_id AND mantida.edicao_id = mantida_id
       AND descartada.criador_id = mantida.criador_id AND descartada.papel = mantida.papel;
    UPDATE creditos_edicoes SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM links_edicoes descartada USING links_edicoes mantida
     WHERE descartada.edicao_id = descartada_id AND mantida.edicao_id = mantida_id
       AND descartada.url = mantida.url;
    UPDATE links_edicoes SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM conteudos_edicoes descartada USING conteudos_edicoes mantida
     WHERE descartada.edicao_id = descartada_id AND mantida.edicao_id = mantida_id
       AND descartada.ordem = mantida.ordem;
    UPDATE conteudos_edicoes SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM publicacoes_historias
     WHERE (edicao_original_id = descartada_id AND edicao_publicada_id = mantida_id)
        OR (edicao_original_id = mantida_id AND edicao_publicada_id = descartada_id);
    UPDATE publicacoes_historias SET edicao_original_id = mantida_id WHERE edicao_original_id = descartada_id;
    DELETE FROM publicacoes_historias descartada USING publicacoes_historias mantida
     WHERE descartada.edicao_publicada_id = descartada_id
       AND mantida.edicao_publicada_id = mantida_id
       AND descartada.historia_id = mantida.historia_id;
    UPDATE publicacoes_historias SET edicao_publicada_id = mantida_id WHERE edicao_publicada_id = descartada_id;

    DELETE FROM publicacoes_relacionadas
     WHERE (edicao_origem_id = descartada_id AND edicao_destino_id = mantida_id)
        OR (edicao_origem_id = mantida_id AND edicao_destino_id = descartada_id);
    UPDATE publicacoes_relacionadas SET edicao_origem_id = mantida_id WHERE edicao_origem_id = descartada_id;
    DELETE FROM publicacoes_relacionadas duplicada USING publicacoes_relacionadas mantida
     WHERE duplicada.id > mantida.id
       AND duplicada.edicao_origem_id = mantida.edicao_origem_id
       AND duplicada.edicao_destino_id = mantida.edicao_destino_id
       AND duplicada.tipo = mantida.tipo;
    UPDATE publicacoes_relacionadas SET edicao_destino_id = mantida_id WHERE edicao_destino_id = descartada_id;
    DELETE FROM publicacoes_relacionadas duplicada USING publicacoes_relacionadas mantida
     WHERE duplicada.id > mantida.id
       AND duplicada.edicao_origem_id = mantida.edicao_origem_id
       AND duplicada.edicao_destino_id = mantida.edicao_destino_id
       AND duplicada.tipo = mantida.tipo;

    UPDATE contribuicoes_catalogo SET edicao_id = mantida_id WHERE edicao_id = descartada_id;
    UPDATE contribuicoes_catalogo SET edicao_destino_id = mantida_id WHERE edicao_destino_id = descartada_id;
    UPDATE itens_ordem_leitura SET edicao_id = mantida_id WHERE edicao_id = descartada_id;
    DELETE FROM edicoes_atividades_estante descartada USING edicoes_atividades_estante mantida
     WHERE descartada.edicao_id = descartada_id AND mantida.edicao_id = mantida_id
       AND descartada.postagem_id = mantida.postagem_id;
    UPDATE edicoes_atividades_estante SET edicao_id = mantida_id WHERE edicao_id = descartada_id;
    DELETE FROM capas_edicao WHERE edicao_id = descartada_id;
    DELETE FROM edicoes WHERE id = descartada_id;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
    canonica_id BIGINT;
    incorreta RECORD;
    edicao_incorreta RECORD;
    edicao_canonica_id BIGINT;
BEGIN
    SELECT serie.id INTO canonica_id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Marvel Epic Collection')
       AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
       AND coalesce(serie.volume, 1) = 1
     ORDER BY serie.id
     LIMIT 1;

    IF canonica_id IS NULL THEN
        RAISE EXCEPTION 'Serie canonica Marvel Epic Collection, Panini V1, nao encontrada.';
    END IF;

    FOR incorreta IN
        SELECT serie.id
          FROM series serie
          JOIN editoras editora ON editora.id = serie.editora_id
         WHERE coalesce(serie.volume, 1) = 1
           AND (
                (hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Marvel Epic Collection Panini')
                 AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%')
                OR
                (hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('Marvel Epic Collection')
                 AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%abril%')
           )
    LOOP
        FOR edicao_incorreta IN SELECT id, numero FROM edicoes WHERE serie_id = incorreta.id LOOP
            SELECT id INTO edicao_canonica_id
              FROM edicoes
             WHERE serie_id = canonica_id
               AND hqhub_normalizar_identidade(numero) = hqhub_normalizar_identidade(edicao_incorreta.numero)
             ORDER BY (url_capa IS NOT NULL AND trim(url_capa) <> '') DESC, id
             LIMIT 1;

            IF edicao_canonica_id IS NULL THEN
                UPDATE edicoes
                   SET serie_id = canonica_id, data_atualizacao = CURRENT_TIMESTAMP
                 WHERE id = edicao_incorreta.id;
            ELSE
                PERFORM hqhub_mesclar_edicao_epic_collection(edicao_incorreta.id, edicao_canonica_id);
            END IF;
        END LOOP;

        DELETE FROM colecoes_series descartada USING colecoes_series mantida
         WHERE descartada.serie_id = incorreta.id AND mantida.serie_id = canonica_id
           AND descartada.usuario_id = mantida.usuario_id;
        UPDATE colecoes_series SET serie_id = canonica_id WHERE serie_id = incorreta.id;
        UPDATE postagens_feed SET serie_catalogo_id = canonica_id WHERE serie_catalogo_id = incorreta.id;

        DELETE FROM relacionamentos_series
         WHERE (serie_origem_id = incorreta.id AND serie_destino_id = canonica_id)
            OR (serie_origem_id = canonica_id AND serie_destino_id = incorreta.id);
        UPDATE relacionamentos_series SET serie_origem_id = canonica_id WHERE serie_origem_id = incorreta.id;
        UPDATE relacionamentos_series SET serie_destino_id = canonica_id WHERE serie_destino_id = incorreta.id;
        DELETE FROM relacionamentos_series duplicada USING relacionamentos_series mantida
         WHERE duplicada.id > mantida.id
           AND duplicada.serie_origem_id = mantida.serie_origem_id
           AND duplicada.serie_destino_id = mantida.serie_destino_id
           AND duplicada.tipo = mantida.tipo;

        DELETE FROM series WHERE id = incorreta.id;
    END LOOP;
END $$;

DROP FUNCTION hqhub_mesclar_edicao_epic_collection(BIGINT, BIGINT);
