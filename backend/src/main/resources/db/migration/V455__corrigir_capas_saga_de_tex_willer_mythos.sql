-- Corrige as capas de A Saga de Tex Willer/Mythos, volume 1.
-- Identidade editorial validada contra a galeria sa062102 do Guia dos Quadrinhos.
-- As imagens oficiais da Mythos ficam no repositorio para evitar hotlink instavel.

WITH referencias(numero) AS (
    VALUES (1), (2), (3)
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE '%mythos%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('A Saga de Tex Willer'),
          hqhub_normalizar_titulo_serie('Saga de Tex Willer, A')
      )
      AND coalesce(serie.volume, 1) = 1
)
UPDATE edicoes edicao
SET url_capa =
        'https://raw.githubusercontent.com/rogeriodesaf/hq-hub/main/' ||
        'backend/src/main/resources/META-INF/resources/capas/' ||
        'a-saga-de-tex-willer-mythos-v1/' || lpad(referencia.numero::text, 2, '0') || '.jpg',
    url_origem = 'https://www.guiadosquadrinhos.com/capas/saga-de-tex-willer-a/sa062102',
    fonte_externa = 'Mythos / Guia dos Quadrinhos',
    data_atualizacao = CURRENT_TIMESTAMP
FROM referencias referencia
CROSS JOIN serie_alvo serie
WHERE edicao.serie_id = serie.id
  AND trim(edicao.numero) ~ '^0*[0-9]+$'
  AND trim(edicao.numero)::integer = referencia.numero
  AND (
      edicao.url_capa IS DISTINCT FROM
          'https://raw.githubusercontent.com/rogeriodesaf/hq-hub/main/' ||
          'backend/src/main/resources/META-INF/resources/capas/' ||
          'a-saga-de-tex-willer-mythos-v1/' || lpad(referencia.numero::text, 2, '0') || '.jpg'
      OR edicao.url_origem IS DISTINCT FROM
          'https://www.guiadosquadrinhos.com/capas/saga-de-tex-willer-a/sa062102'
      OR edicao.fonte_externa IS DISTINCT FROM 'Mythos / Guia dos Quadrinhos'
  );

-- Mantem os guias de leitura sincronizados com as capas corrigidas.
WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE '%mythos%'
      AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('A Saga de Tex Willer'),
          hqhub_normalizar_titulo_serie('Saga de Tex Willer, A')
      )
      AND coalesce(serie.volume, 1) = 1
)
UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao
WHERE item.edicao_id = edicao.id
  AND edicao.serie_id IN (SELECT id FROM serie_alvo)
  AND trim(edicao.numero) ~ '^0*[0-9]+$'
  AND trim(edicao.numero)::integer BETWEEN 1 AND 3
  AND item.url_capa_referencia IS DISTINCT FROM edicao.url_capa;
