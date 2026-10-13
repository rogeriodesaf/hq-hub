-- Corrige as capas da colecao completa Saga da Liga da Justica, A - 3a Serie,
-- Panini, volume 3, edicoes 1 a 5 (abril a dezembro de 2025).
--
-- Identidade editorial validada na galeria dedicada sa011300 do Guia dos
-- Quadrinhos: titulo, editora Panini, terceira serie e cinco edicoes. Cada
-- pagina individual e cada imagem responderam HTTP 200/image-jpeg em sessao
-- autenticada; o conjunto completo foi conferido visualmente e traz na arte
-- os volumes 1/24, 2/25, 3/26, 4/27 e 5/28.
--
-- Evidencia auditavel (pagina por edicao, URL da imagem, dimensoes, bytes e
-- SHA-256 dos cinco arquivos):
-- docs/catalogo/capas/saga-liga-justica-panini-v3.csv

DO $$
DECLARE
    serie_alvo_id BIGINT;
    quantidade_series INTEGER;
    quantidade_edicoes INTEGER;
    quantidade_numeros INTEGER;
BEGIN
    SELECT count(*), min(serie.id)
      INTO quantidade_series, serie_alvo_id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Panini')
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie(U&'Saga da Liga da Justi\00E7a, A 3\00AA S\00E9rie')
       AND coalesce(serie.volume, 1) = 3
       AND serie.id_externo =
           U&'panini|saga da liga da justi\00E7a, a 3\00AA s\00E9rie|3';

    -- A importacao pode ainda nao existir em um ambiente novo.
    IF quantidade_series = 0 THEN
        RETURN;
    END IF;

    IF quantidade_series <> 1 THEN
        RAISE EXCEPTION
            'Saga da Liga da Justica, A - 3a Serie/Panini V3: esperada uma serie alvo, encontradas %',
            quantidade_series;
    END IF;

    SELECT count(*),
           count(DISTINCT trim(edicao.numero)::integer)
      INTO quantidade_edicoes, quantidade_numeros
      FROM edicoes edicao
     WHERE edicao.serie_id = serie_alvo_id
       AND trim(edicao.numero) ~ '^0*[1-5]$';

    IF quantidade_edicoes <> 5 OR quantidade_numeros <> 5 THEN
        RAISE EXCEPTION
            'Saga da Liga da Justica, A - 3a Serie/Panini V3: esperadas cinco edicoes unicas de 1 a 5, encontradas % edicoes e % numeros; nenhuma capa foi alterada',
            quantidade_edicoes,
            quantidade_numeros;
    END IF;

    IF EXISTS (
        SELECT 1
          FROM edicoes edicao
         WHERE edicao.serie_id = serie_alvo_id
           AND (
               trim(edicao.numero) !~ '^0*[1-5]$'
               OR trim(edicao.numero)::integer NOT BETWEEN 1 AND 5
           )
    ) THEN
        RAISE EXCEPTION
            'Saga da Liga da Justica, A - 3a Serie/Panini V3: existem edicoes fora do conjunto validado 1-5; nenhuma capa foi alterada';
    END IF;
END
$$;

WITH capas(numero, url_edicao) AS (
    VALUES
        (1, 'https://www.guiadosquadrinhos.com/edicao/saga-da-liga-da-justica-a-3-serie-n-1/sa011300/184570'),
        (2, 'https://www.guiadosquadrinhos.com/edicao/saga-da-liga-da-justica-a-3-serie-n-2/sa011300/185060'),
        (3, 'https://www.guiadosquadrinhos.com/edicao/saga-da-liga-da-justica-a-3-serie-n-3/sa011300/186013'),
        (4, 'https://www.guiadosquadrinhos.com/edicao/saga-da-liga-da-justica-a-3-serie-n-4/sa011300/186939'),
        (5, 'https://www.guiadosquadrinhos.com/edicao/saga-da-liga-da-justica-a-3-serie-n-5/sa011300/187811')
), serie_alvo AS (
    SELECT serie.id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Panini')
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie(U&'Saga da Liga da Justi\00E7a, A 3\00AA S\00E9rie')
       AND coalesce(serie.volume, 1) = 3
       AND serie.id_externo =
           U&'panini|saga da liga da justi\00E7a, a 3\00AA s\00E9rie|3'
)
UPDATE edicoes edicao
   SET url_capa =
           'https://raw.githubusercontent.com/rogeriodesaf/hq-hub/main/' ||
           'backend/src/main/resources/META-INF/resources/capas/' ||
           'saga-liga-justica-panini-v3/' ||
           lpad(capa.numero::text, 3, '0') || '.jpg',
       url_origem = capa.url_edicao,
       fonte_externa = 'Guia dos Quadrinhos',
       data_atualizacao = CURRENT_TIMESTAMP
  FROM capas capa
 CROSS JOIN serie_alvo serie
 WHERE edicao.serie_id = serie.id
   AND trim(edicao.numero) ~ '^0*[1-5]$'
   AND trim(edicao.numero)::integer = capa.numero;

-- Mantem eventuais guias de leitura sincronizados com as capas corrigidas.
WITH serie_alvo AS (
    SELECT serie.id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Panini')
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie(U&'Saga da Liga da Justi\00E7a, A 3\00AA S\00E9rie')
       AND coalesce(serie.volume, 1) = 3
       AND serie.id_externo =
           U&'panini|saga da liga da justi\00E7a, a 3\00AA s\00E9rie|3'
)
UPDATE itens_ordem_leitura item
   SET url_capa_referencia = edicao.url_capa
  FROM edicoes edicao
 WHERE item.edicao_id = edicao.id
   AND edicao.serie_id IN (SELECT id FROM serie_alvo)
   AND trim(edicao.numero) ~ '^0*[1-5]$'
   AND item.url_capa_referencia IS DISTINCT FROM edicao.url_capa;
