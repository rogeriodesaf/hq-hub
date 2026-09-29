-- Corrige as 42 capas de Dragon Ball/Panini, volume 1.
-- Identidade editorial validada contra a galeria dr011101 do Guia dos Quadrinhos:
-- Dragon Ball, Panini, serie completa de 42 volumes (2012-2015).
-- As imagens correspondentes foram obtidas da colecao oficial DRAGON BALL (AMADR)
-- da Panini e ficam no repositorio para evitar indisponibilidade por hotlink.

WITH capas(numero) AS (
    SELECT generate_series(1, 42)
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Dragon Ball')
      AND coalesce(serie.volume, 1) = 1
)
UPDATE edicoes edicao
SET url_capa =
        'https://raw.githubusercontent.com/rogeriodesaf/hq-hub/main/' ||
        'backend/src/main/resources/META-INF/resources/capas/' ||
        'dragon-ball-panini-v1/' || lpad(capa.numero::text, 2, '0') || '.jpg',
    url_origem = 'https://www.guiadosquadrinhos.com/capas/dragon-ball/dr011101',
    fonte_externa = 'Panini / Guia dos Quadrinhos',
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
          'dragon-ball-panini-v1/' || lpad(capa.numero::text, 2, '0') || '.jpg'
      OR edicao.url_origem IS DISTINCT FROM
          'https://www.guiadosquadrinhos.com/capas/dragon-ball/dr011101'
      OR edicao.fonte_externa IS DISTINCT FROM 'Panini / Guia dos Quadrinhos'
  );

-- Mantem eventuais guias de leitura sincronizados com as capas corrigidas.
WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Dragon Ball')
      AND coalesce(serie.volume, 1) = 1
)
UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao
WHERE item.edicao_id = edicao.id
  AND edicao.serie_id IN (SELECT id FROM serie_alvo)
  AND trim(edicao.numero) ~ '^0*[0-9]+$'
  AND trim(edicao.numero)::integer BETWEEN 1 AND 42
  AND item.url_capa_referencia IS DISTINCT FROM edicao.url_capa;
