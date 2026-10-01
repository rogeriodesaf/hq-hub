-- Corrige as 246 capas de Cebolinha/Globo, volume 1 (1987-2006).
-- Identidade editorial e sequencia validadas contra a galeria ce00501 do Guia
-- dos Quadrinhos. As imagens vieram da colecao dedicada Cebolinha Globo do
-- acervo Get Back e ficam no repositorio para evitar hotlink instavel.

WITH capas(numero) AS (
    SELECT generate_series(1, 246)
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE '%globo%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Cebolinha')
      AND coalesce(serie.volume, 1) = 1
)
UPDATE edicoes edicao
SET url_capa =
        'https://raw.githubusercontent.com/rogeriodesaf/hq-hub/main/' ||
        'backend/src/main/resources/META-INF/resources/capas/' ||
        'cebolinha-globo-v1/' || lpad(capa.numero::text, 3, '0') || '.jpg',
    url_origem = 'https://www.guiadosquadrinhos.com/capas/cebolinha/ce00501',
    fonte_externa = 'Get Back / Guia dos Quadrinhos',
    data_atualizacao = CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_alvo serie
WHERE edicao.serie_id = serie.id
  AND trim(edicao.numero) ~ '^0*[0-9]+$'
  AND trim(edicao.numero)::integer = capa.numero
  AND (
      edicao.url_capa IS DISTINCT FROM
          'https://raw.githubusercontent.com/rogeriodesaf/hq-hub/main/' ||
          'backend/src/main/resources/META-INF/resources/capas/' ||
          'cebolinha-globo-v1/' || lpad(capa.numero::text, 3, '0') || '.jpg'
      OR edicao.url_origem IS DISTINCT FROM
          'https://www.guiadosquadrinhos.com/capas/cebolinha/ce00501'
      OR edicao.fonte_externa IS DISTINCT FROM 'Get Back / Guia dos Quadrinhos'
  );

-- Mantem eventuais guias de leitura sincronizados com as capas corrigidas.
WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE '%globo%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Cebolinha')
      AND coalesce(serie.volume, 1) = 1
)
UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao
WHERE item.edicao_id = edicao.id
  AND edicao.serie_id IN (SELECT id FROM serie_alvo)
  AND trim(edicao.numero) ~ '^0*[0-9]+$'
  AND trim(edicao.numero)::integer BETWEEN 1 AND 246
  AND item.url_capa_referencia IS DISTINCT FROM edicao.url_capa;
