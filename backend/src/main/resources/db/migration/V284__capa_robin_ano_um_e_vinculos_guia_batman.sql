-- Aplica a capa oficial de Robin: Ano Um (Panini, 2024) e vincula ao guia
-- essa edicao e Batman: Ano Dois - Edicao de Luxo.

WITH referencia AS (
    SELECT
        'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_blost3jafh5q78suihssopu11r/-S897-f.webp'::text AS url_capa,
        'https://panini.com.br/robin-ano-um'::text AS url_origem
)
UPDATE edicoes edicao
SET url_capa = referencia.url_capa,
    fonte_externa = 'PANINI',
    id_externo = coalesce(nullif(edicao.id_externo, ''), 'AROAU001'),
    url_origem = referencia.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM referencia, series serie, editoras editora
WHERE serie.id = edicao.serie_id
  AND editora.id = serie.editora_id
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
  AND (
      hqhub_normalizar_titulo_serie(edicao.titulo) =
          hqhub_normalizar_titulo_serie('Robin: Ano Um')
      OR hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Robin: Ano Um')
  );

WITH edicao_robin AS (
    SELECT edicao.id, edicao.url_capa
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND (
          hqhub_normalizar_titulo_serie(edicao.titulo) =
              hqhub_normalizar_titulo_serie('Robin: Ano Um')
          OR hqhub_normalizar_titulo_serie(serie.titulo) =
              hqhub_normalizar_titulo_serie('Robin: Ano Um')
      )
    ORDER BY
        CASE WHEN upper(coalesce(edicao.id_externo, '')) = 'AROAU001' THEN 0 ELSE 1 END,
        edicao.data_publicacao DESC NULLS LAST,
        edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = edicao.id,
    url_capa_referencia = edicao.url_capa,
    status_identificacao = 'CONFIRMADO',
    observacao = 'Vinculada a edicao brasileira Robin: Ano Um da Panini (referencia AROAU001).',
    ano_referencia = 2024
FROM edicao_robin edicao
JOIN ordens_leitura ordem ON ordem.slug = 'batman-ordem-cronologica'
WHERE item.ordem_leitura_id = ordem.id
  AND hqhub_normalizar_titulo_serie(item.titulo_referencia) =
      hqhub_normalizar_titulo_serie('Robin: Ano Um');

WITH edicao_ano_dois AS (
    SELECT edicao.id, edicao.url_capa
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
      AND (
          hqhub_normalizar_titulo_serie(edicao.titulo) IN (
              hqhub_normalizar_titulo_serie('Batman: Ano Dois - Edição de Luxo'),
              hqhub_normalizar_titulo_serie('Batman: Ano Dois'),
              hqhub_normalizar_titulo_serie('Batman - Ano Dois - Edição de Luxo')
          )
          OR hqhub_normalizar_titulo_serie(serie.titulo) IN (
              hqhub_normalizar_titulo_serie('Batman: Ano Dois - Edição de Luxo'),
              hqhub_normalizar_titulo_serie('Batman: Ano Dois'),
              hqhub_normalizar_titulo_serie('Batman - Ano Dois - Edição de Luxo')
          )
      )
    ORDER BY
        CASE
            WHEN hqhub_normalizar_titulo_serie(edicao.titulo) LIKE '%edicaodeluxo%'
              OR hqhub_normalizar_titulo_serie(serie.titulo) LIKE '%edicaodeluxo%'
            THEN 0 ELSE 1
        END,
        edicao.data_publicacao DESC NULLS LAST,
        edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = edicao.id,
    url_capa_referencia = edicao.url_capa,
    status_identificacao = 'CONFIRMADO',
    observacao = 'Vinculada a Batman: Ano Dois - Edicao de Luxo, publicada pela Panini em 2020.',
    ano_referencia = 2020
FROM edicao_ano_dois edicao
JOIN ordens_leitura ordem ON ordem.slug = 'batman-ordem-cronologica'
WHERE item.ordem_leitura_id = ordem.id
  AND hqhub_normalizar_titulo_serie(item.titulo_referencia) =
      hqhub_normalizar_titulo_serie('Batman: Ano Dois');
