-- Corrige o cadastro informado pelo usuario: a serie Chico Bento foi vinculada
-- por engano a Panini, mas esta colecao pertence a Editora Globo.
-- Se a serie Globo ja existir, consolida nela a duplicata Panini, preservando
-- edicoes e vinculos. A migracao anterior falhou antes de ser aplicada quando
-- encontrou exatamente esse cenario no banco de producao.
CREATE OR REPLACE FUNCTION hqhub_mesclar_edicao_chico_bento(
    descartada_id BIGINT,
    mantida_id BIGINT
)
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

    DELETE FROM itens_colecao descartado
     USING itens_colecao mantido
     WHERE descartado.edicao_id = descartada_id
       AND mantido.edicao_id = mantida_id
       AND descartado.usuario_id = mantido.usuario_id;
    UPDATE itens_colecao SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM compras_planejadas descartada
     USING compras_planejadas mantida
     WHERE descartada.edicao_id = descartada_id
       AND mantida.edicao_id = mantida_id
       AND descartada.usuario_id = mantida.usuario_id
       AND descartada.mes = mantida.mes
       AND descartada.ano = mantida.ano;
    UPDATE compras_planejadas SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM creditos_edicoes descartado
     USING creditos_edicoes mantido
     WHERE descartado.edicao_id = descartada_id
       AND mantido.edicao_id = mantida_id
       AND descartado.criador_id = mantido.criador_id
       AND descartado.papel = mantido.papel;
    UPDATE creditos_edicoes SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM links_edicoes descartado
     USING links_edicoes mantido
     WHERE descartado.edicao_id = descartada_id
       AND mantido.edicao_id = mantida_id
       AND descartado.url = mantido.url;
    UPDATE links_edicoes SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM conteudos_edicoes descartado
     USING conteudos_edicoes mantido
     WHERE descartado.edicao_id = descartada_id
       AND mantido.edicao_id = mantida_id
       AND descartado.ordem = mantido.ordem;
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
    UPDATE itens_ordem_leitura SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM edicoes_atividades_estante descartada
     USING edicoes_atividades_estante mantida
     WHERE descartada.edicao_id = descartada_id
       AND mantida.edicao_id = mantida_id
       AND descartada.postagem_id = mantida.postagem_id;
    UPDATE edicoes_atividades_estante SET edicao_id = mantida_id WHERE edicao_id = descartada_id;

    DELETE FROM edicoes WHERE id = descartada_id;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
    serie_chico_bento_id BIGINT;
    serie_globo_id BIGINT;
    editora_globo_id BIGINT;
    quantidade BIGINT;
    edicao_panini RECORD;
    edicao_globo_id BIGINT;
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

    SELECT count(*), min(destino.id)
      INTO quantidade, serie_globo_id
      FROM series origem
      JOIN series destino
        ON destino.editora_id = editora_globo_id
       AND destino.id <> origem.id
       AND hqhub_normalizar_titulo_serie(destino.titulo) =
           hqhub_normalizar_titulo_serie(origem.titulo)
       AND COALESCE(destino.volume, 0) = COALESCE(origem.volume, 0)
     WHERE origem.id = serie_chico_bento_id;

    IF quantidade > 1 THEN
        RAISE EXCEPTION 'Chico Bento: mais de uma serie Globo com o mesmo volume (%)', quantidade;
    END IF;

    IF quantidade = 0 THEN
        UPDATE series
           SET editora_id = editora_globo_id,
               data_atualizacao = CURRENT_TIMESTAMP
         WHERE id = serie_chico_bento_id;
        RAISE NOTICE 'Chico Bento: serie % transferida para a editora Globo %',
            serie_chico_bento_id, editora_globo_id;
    ELSE
        PERFORM id FROM series WHERE id = serie_globo_id FOR UPDATE;
        PERFORM id FROM edicoes
         WHERE serie_id IN (serie_chico_bento_id, serie_globo_id)
         ORDER BY id FOR UPDATE;

        FOR edicao_panini IN
            SELECT id, numero FROM edicoes
             WHERE serie_id = serie_chico_bento_id ORDER BY id
        LOOP
            SELECT id INTO edicao_globo_id
              FROM edicoes
             WHERE serie_id = serie_globo_id
               AND hqhub_normalizar_identidade(numero) =
                   hqhub_normalizar_identidade(edicao_panini.numero)
             ORDER BY id LIMIT 1;

            IF edicao_globo_id IS NULL THEN
                UPDATE edicoes
                   SET serie_id = serie_globo_id,
                       data_atualizacao = CURRENT_TIMESTAMP
                 WHERE id = edicao_panini.id;
            ELSE
                PERFORM hqhub_mesclar_edicao_chico_bento(edicao_panini.id, edicao_globo_id);
            END IF;
        END LOOP;

        DELETE FROM colecoes_series descartada
         USING colecoes_series mantida
         WHERE descartada.serie_id = serie_chico_bento_id
           AND mantida.serie_id = serie_globo_id
           AND descartada.usuario_id = mantida.usuario_id;
        UPDATE colecoes_series
           SET serie_id = serie_globo_id, data_atualizacao = CURRENT_TIMESTAMP
         WHERE serie_id = serie_chico_bento_id;

        UPDATE postagens_feed SET serie_catalogo_id = serie_globo_id
         WHERE serie_catalogo_id = serie_chico_bento_id;

        DELETE FROM relacionamentos_series
         WHERE (serie_origem_id = serie_chico_bento_id AND serie_destino_id = serie_globo_id)
            OR (serie_origem_id = serie_globo_id AND serie_destino_id = serie_chico_bento_id);
        UPDATE relacionamentos_series SET serie_origem_id = serie_globo_id
         WHERE serie_origem_id = serie_chico_bento_id;
        UPDATE relacionamentos_series SET serie_destino_id = serie_globo_id
         WHERE serie_destino_id = serie_chico_bento_id;
        DELETE FROM relacionamentos_series duplicado
         USING relacionamentos_series mantido
         WHERE duplicado.id > mantido.id
           AND duplicado.serie_origem_id = mantido.serie_origem_id
           AND duplicado.serie_destino_id = mantido.serie_destino_id
           AND duplicado.tipo = mantido.tipo;

        DELETE FROM series WHERE id = serie_chico_bento_id;
        RAISE NOTICE 'Chico Bento: serie Panini % consolidada na serie Globo %',
            serie_chico_bento_id, serie_globo_id;
    END IF;
END $$;

DROP FUNCTION hqhub_mesclar_edicao_chico_bento(BIGINT, BIGINT);
