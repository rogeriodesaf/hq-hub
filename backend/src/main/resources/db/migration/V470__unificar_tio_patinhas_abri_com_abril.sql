-- Corrige o titulo truncado informado pelo usuario. As edicoes de
-- "Tio Patinhas Abri" / Abril, volume 1, pertencem ao cadastro canonico
-- "Tio Patinhas Abril" / Abril, volume 1.
--
-- A identidade editorial e limitada a Editora Abril, volume 1, e aos numeros
-- 1 a 637 da galeria tph0031 do Guia dos Quadrinhos. Depois da consolidacao,
-- as capas auditadas pela V469 sao reaplicadas ao titulo canonico.

CREATE OR REPLACE FUNCTION hqhub_mesclar_edicao_tio_patinhas_abril(
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

    UPDATE postagens_feed postagem
       SET item_colecao_id = item_mantido.id
      FROM itens_colecao item_descartado
      JOIN itens_colecao item_mantido
        ON item_mantido.usuario_id = item_descartado.usuario_id
       AND item_mantido.edicao_id = mantida_id
     WHERE postagem.item_colecao_id = item_descartado.id
       AND item_descartado.edicao_id = descartada_id;

    UPDATE edicoes_atividades_estante atividade
       SET item_colecao_id = item_mantido.id
      FROM itens_colecao item_descartado
      JOIN itens_colecao item_mantido
        ON item_mantido.usuario_id = item_descartado.usuario_id
       AND item_mantido.edicao_id = mantida_id
     WHERE atividade.item_colecao_id = item_descartado.id
       AND item_descartado.edicao_id = descartada_id;

    DELETE FROM curtidas_itens_colecao curtida_descartada
     USING itens_colecao item_descartado,
           itens_colecao item_mantido,
           curtidas_itens_colecao curtida_mantida
     WHERE item_descartado.edicao_id = descartada_id
       AND item_mantido.usuario_id = item_descartado.usuario_id
       AND item_mantido.edicao_id = mantida_id
       AND curtida_descartada.item_colecao_id = item_descartado.id
       AND curtida_mantida.item_colecao_id = item_mantido.id
       AND curtida_mantida.usuario_id = curtida_descartada.usuario_id;
    UPDATE curtidas_itens_colecao curtida
       SET item_colecao_id = item_mantido.id
      FROM itens_colecao item_descartado
      JOIN itens_colecao item_mantido
        ON item_mantido.usuario_id = item_descartado.usuario_id
       AND item_mantido.edicao_id = mantida_id
     WHERE curtida.item_colecao_id = item_descartado.id
       AND item_descartado.edicao_id = descartada_id;

    UPDATE comentarios_itens_colecao comentario
       SET item_colecao_id = item_mantido.id
      FROM itens_colecao item_descartado
      JOIN itens_colecao item_mantido
        ON item_mantido.usuario_id = item_descartado.usuario_id
       AND item_mantido.edicao_id = mantida_id
     WHERE comentario.item_colecao_id = item_descartado.id
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
<<unificacao>>
DECLARE
    serie_origem_id BIGINT;
    serie_destino_id BIGINT;
    quantidade INTEGER;
    edicoes_invalidas INTEGER;
    numeros_duplicados INTEGER;
    edicao_origem RECORD;
    edicao_destino_id BIGINT;
BEGIN
    SELECT count(*), min(serie.id)
      INTO quantidade, serie_origem_id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) IN (
               hqhub_normalizar_titulo_serie('Abril'),
               hqhub_normalizar_titulo_serie('Editora Abril')
           )
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie('Tio Patinhas Abri')
       AND coalesce(serie.volume, 1) = 1;

    IF quantidade = 0 THEN
        RETURN; -- O cadastro incorreto nao existe ou ja foi removido.
    END IF;
    IF quantidade <> 1 THEN
        RAISE EXCEPTION
            'Tio Patinhas Abri/Abril V1: esperado um cadastro de origem, encontrados %',
            quantidade;
    END IF;

    SELECT count(*), min(serie.id)
      INTO quantidade, serie_destino_id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) IN (
               hqhub_normalizar_titulo_serie('Abril'),
               hqhub_normalizar_titulo_serie('Editora Abril')
           )
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie('Tio Patinhas Abril')
       AND coalesce(serie.volume, 1) = 1;

    IF quantidade <> 1 THEN
        RAISE EXCEPTION
            'Tio Patinhas Abril/Abril V1: esperado um cadastro de destino, encontrados %',
            quantidade;
    END IF;

    PERFORM id FROM series
     WHERE id IN (serie_origem_id, serie_destino_id)
     ORDER BY id
     FOR UPDATE;
    PERFORM id FROM edicoes
     WHERE serie_id IN (serie_origem_id, serie_destino_id)
     ORDER BY id
     FOR UPDATE;

    SELECT count(*)
      INTO edicoes_invalidas
      FROM edicoes edicao
     WHERE edicao.serie_id IN (serie_origem_id, serie_destino_id)
       AND (
           trim(edicao.numero) !~ '^0*[1-9][0-9]*$'
           OR trim(edicao.numero)::numeric NOT BETWEEN 1 AND 637
       );

    IF edicoes_invalidas <> 0 THEN
        RAISE EXCEPTION
            'Tio Patinhas Abril/Abril V1: existem % edicoes fora da identidade numerica 1-637 da galeria tph0031',
            edicoes_invalidas;
    END IF;

    SELECT count(*)
      INTO numeros_duplicados
      FROM (
          SELECT edicao.serie_id, trim(edicao.numero)::integer AS numero
            FROM edicoes edicao
           WHERE edicao.serie_id IN (serie_origem_id, serie_destino_id)
           GROUP BY edicao.serie_id, trim(edicao.numero)::integer
          HAVING count(*) > 1
      ) duplicados;

    IF numeros_duplicados <> 0 THEN
        RAISE EXCEPTION
            'Tio Patinhas Abril/Abril V1: existem % numeros duplicados dentro de um dos cadastros',
            numeros_duplicados;
    END IF;

    FOR edicao_origem IN
        SELECT id, numero
          FROM edicoes
         WHERE serie_id = serie_origem_id
         ORDER BY trim(numero)::integer, id
    LOOP
        SELECT id
          INTO edicao_destino_id
          FROM edicoes
         WHERE serie_id = serie_destino_id
           AND trim(numero) ~ '^0*[1-9][0-9]*$'
           AND trim(numero)::integer = trim(edicao_origem.numero)::integer
         ORDER BY id
         LIMIT 1;

        IF edicao_destino_id IS NULL THEN
            UPDATE edicoes
               SET serie_id = serie_destino_id,
                   data_atualizacao = CURRENT_TIMESTAMP
             WHERE id = edicao_origem.id;
        ELSE
            UPDATE edicoes mantida
               SET titulo = coalesce(nullif(mantida.titulo, ''), descartada.titulo),
                   descricao = coalesce(nullif(mantida.descricao, ''), descartada.descricao),
                   data_publicacao = coalesce(mantida.data_publicacao, descartada.data_publicacao),
                   url_capa = coalesce(nullif(mantida.url_capa, ''), descartada.url_capa),
                   codigo_barras = coalesce(nullif(mantida.codigo_barras, ''), descartada.codigo_barras),
                   quantidade_paginas = coalesce(mantida.quantidade_paginas, descartada.quantidade_paginas),
                   preco_capa = coalesce(mantida.preco_capa, descartada.preco_capa),
                   formato = coalesce(nullif(mantida.formato, ''), descartada.formato),
                   data_atualizacao = CURRENT_TIMESTAMP
              FROM edicoes descartada
             WHERE mantida.id = edicao_destino_id
               AND descartada.id = edicao_origem.id;

            PERFORM hqhub_mesclar_edicao_tio_patinhas_abril(
                edicao_origem.id,
                edicao_destino_id
            );
        END IF;
    END LOOP;

    DELETE FROM colecoes_series descartada
     USING colecoes_series mantida
     WHERE descartada.serie_id = serie_origem_id
       AND mantida.serie_id = serie_destino_id
       AND descartada.usuario_id = mantida.usuario_id;
    UPDATE colecoes_series
       SET serie_id = serie_destino_id,
           data_atualizacao = CURRENT_TIMESTAMP
     WHERE serie_id = serie_origem_id;

    UPDATE postagens_feed
       SET serie_catalogo_id = serie_destino_id
     WHERE serie_catalogo_id = serie_origem_id;

    DELETE FROM relacionamentos_series relacao
     WHERE (relacao.serie_origem_id = unificacao.serie_origem_id
            AND relacao.serie_destino_id = unificacao.serie_destino_id)
        OR (relacao.serie_origem_id = unificacao.serie_destino_id
            AND relacao.serie_destino_id = unificacao.serie_origem_id);
    UPDATE relacionamentos_series relacao
       SET serie_origem_id = unificacao.serie_destino_id
     WHERE relacao.serie_origem_id = unificacao.serie_origem_id;
    UPDATE relacionamentos_series relacao
       SET serie_destino_id = unificacao.serie_destino_id
     WHERE relacao.serie_destino_id = unificacao.serie_origem_id;
    DELETE FROM relacionamentos_series duplicado
     USING relacionamentos_series mantido
     WHERE duplicado.id > mantido.id
       AND duplicado.serie_origem_id = mantido.serie_origem_id
       AND duplicado.serie_destino_id = mantido.serie_destino_id
       AND duplicado.tipo = mantido.tipo;

    DELETE FROM series WHERE id = serie_origem_id;
END
$$;

DROP FUNCTION hqhub_mesclar_edicao_tio_patinhas_abril(BIGINT, BIGINT);

-- Reaplica as 637 capas auditadas na V469, agora ao titulo canonico correto.
WITH capas(numero) AS (
    SELECT numero FROM generate_series(1, 637) AS sequencia(numero)
), serie_alvo AS (
    SELECT serie.id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) IN (
               hqhub_normalizar_titulo_serie('Abril'),
               hqhub_normalizar_titulo_serie('Editora Abril')
           )
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie('Tio Patinhas Abril')
       AND coalesce(serie.volume, 1) = 1
)
UPDATE edicoes edicao
   SET url_capa =
           'https://raw.githubusercontent.com/rogeriodesaf/hq-hub/main/' ||
           'backend/src/main/resources/META-INF/resources/capas/' ||
           'tio-patinhas-abril-v1/' || lpad(capa.numero::text, 3, '0') || '.jpg',
       url_origem = 'https://www.guiadosquadrinhos.com/capas/tio-patinhas/tph0031',
       fonte_externa = 'Vila Xurupita / Guia dos Quadrinhos',
       data_atualizacao = CURRENT_TIMESTAMP
  FROM capas capa
 CROSS JOIN serie_alvo serie
 WHERE edicao.serie_id = serie.id
   AND trim(edicao.numero) ~ '^0*[1-9][0-9]*$'
   AND trim(edicao.numero)::integer = capa.numero;

UPDATE itens_ordem_leitura item
   SET url_capa_referencia = edicao.url_capa
  FROM edicoes edicao
  JOIN series serie ON serie.id = edicao.serie_id
  JOIN editoras editora ON editora.id = serie.editora_id
 WHERE item.edicao_id = edicao.id
   AND hqhub_normalizar_titulo_serie(editora.nome) IN (
           hqhub_normalizar_titulo_serie('Abril'),
           hqhub_normalizar_titulo_serie('Editora Abril')
       )
   AND hqhub_normalizar_titulo_serie(serie.titulo) =
       hqhub_normalizar_titulo_serie('Tio Patinhas Abril')
   AND coalesce(serie.volume, 1) = 1
   AND trim(edicao.numero) ~ '^0*[1-9][0-9]*$'
   AND trim(edicao.numero)::integer BETWEEN 1 AND 637
   AND item.url_capa_referencia IS DISTINCT FROM edicao.url_capa;
