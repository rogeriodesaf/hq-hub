-- Corrige as capas das edicoes 10 a 13 de Superman 7a Serie - Sem Limites,
-- Panini, volume 7. A fonte unica e a loja oficial da Panini.
--
-- Identidade editorial validada em 2026-10-26: os quatro produtos pertencem
-- a colecao SUPERMAN (2025) N.01, usam os SKUs ASPMN010 a ASPMN013 e as
-- paginas oficiais identificam explicitamente os numeros 10, 11, 12 e 13.
-- Todas as URLs de capa abaixo responderam HTTP 200/image-webp e o conjunto
-- foi conferido visualmente; as edicoes 10 a 12 exibem na propria arte o selo
-- DC Sem Limites e o numero correspondente. A edicao 13 usa a arte oficial
-- atualmente publicada pela Panini para o SKU ASPMN013.

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
           hqhub_normalizar_titulo_serie(
               U&'Superman 7\00AA S\00E9rie - Sem Limites'
           )
       AND coalesce(serie.volume, 1) = 7
       AND serie.id_externo =
           U&'panini|superman 7\00AA s\00E9rie|7';

    -- A serie e suas edicoes podem ainda nao existir em um ambiente novo.
    IF quantidade_series = 0 THEN
        RETURN;
    END IF;

    IF quantidade_series <> 1 THEN
        RAISE EXCEPTION
            'Superman 7a Serie - Sem Limites/Panini V7: esperada uma serie alvo, encontradas %',
            quantidade_series;
    END IF;

    SELECT count(*),
           count(DISTINCT trim(edicao.numero)::integer)
      INTO quantidade_edicoes, quantidade_numeros
      FROM edicoes edicao
     WHERE edicao.serie_id = serie_alvo_id
       AND trim(edicao.numero) ~ '^0*(10|11|12|13)$';

    IF quantidade_edicoes <> 4 OR quantidade_numeros <> 4 THEN
        RAISE EXCEPTION
            'Superman 7a Serie - Sem Limites/Panini V7: esperadas quatro edicoes unicas de 10 a 13, encontradas % edicoes e % numeros; nenhuma capa foi alterada',
            quantidade_edicoes,
            quantidade_numeros;
    END IF;
END
$$;

WITH capas(numero, sku, url_capa) AS (
    VALUES
        (10, 'ASPMN010', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_cidpgfqrmp6id8njjdlkgd515r/-S500-FWEBP'),
        (11, 'ASPMN011', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_0a0shet3gt7kda8360ql6dsa1j/-S500-FWEBP'),
        (12, 'ASPMN012', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_ets4ir5h3h03199pump8mcui3n/-S500-FWEBP'),
        (13, 'ASPMN013', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_c3hlkbsmgl7nl3sktlre885851/-S500-FWEBP')
), serie_alvo AS (
    SELECT serie.id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Panini')
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie(
               U&'Superman 7\00AA S\00E9rie - Sem Limites'
           )
       AND coalesce(serie.volume, 1) = 7
       AND serie.id_externo =
           U&'panini|superman 7\00AA s\00E9rie|7'
)
UPDATE edicoes edicao
   SET url_capa = capa.url_capa,
       url_origem = 'https://panini.com.br/superman-2025-' || capa.numero,
       fonte_externa = 'Panini',
       data_atualizacao = CURRENT_TIMESTAMP
  FROM capas capa
 CROSS JOIN serie_alvo serie
 WHERE edicao.serie_id = serie.id
   AND trim(edicao.numero) ~ '^0*(10|11|12|13)$'
   AND trim(edicao.numero)::integer = capa.numero;

-- Mantem eventuais guias de leitura sincronizados com as capas corrigidas.
WITH serie_alvo AS (
    SELECT serie.id
      FROM series serie
      JOIN editoras editora ON editora.id = serie.editora_id
     WHERE hqhub_normalizar_titulo_serie(editora.nome) =
           hqhub_normalizar_titulo_serie('Panini')
       AND hqhub_normalizar_titulo_serie(serie.titulo) =
           hqhub_normalizar_titulo_serie(
               U&'Superman 7\00AA S\00E9rie - Sem Limites'
           )
       AND coalesce(serie.volume, 1) = 7
       AND serie.id_externo =
           U&'panini|superman 7\00AA s\00E9rie|7'
)
UPDATE itens_ordem_leitura item
   SET url_capa_referencia = edicao.url_capa
  FROM edicoes edicao
 WHERE item.edicao_id = edicao.id
   AND edicao.serie_id IN (SELECT id FROM serie_alvo)
   AND trim(edicao.numero) ~ '^0*(10|11|12|13)$'
   AND item.url_capa_referencia IS DISTINCT FROM edicao.url_capa;
