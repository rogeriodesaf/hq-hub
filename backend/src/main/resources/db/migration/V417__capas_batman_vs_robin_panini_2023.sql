-- Capas oficiais das cinco edicoes de Batman Vs. Robin, Panini, iniciada em 2023.
WITH capas(numero, referencia, url_capa, url_origem) AS (
    VALUES
        (1, 'ABVSR001',
         'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_kt9r70sn8109j7ahi4haqgfl3r/-S897-FWEBP',
         'https://panini.com.br/batman-vs-robin-01'),
        (2, 'ABVSR002',
         'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_1mfflb5qul2j9bepvf9fk5c43c/-S897-FWEBP',
         'https://panini.com.br/batman-vs-robin-02'),
        (3, 'ABVSR003',
         'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_rkq5qefbdt5919u9s97o9eri30/-S897-FWEBP',
         'https://panini.com.br/batman-vs-robin-03'),
        (4, 'ABVSR004',
         'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_49j5htgncp081fsjfs8u2s7f11/-S897-FWEBP',
         'https://panini.com.br/batman-vs-robin-04'),
        (5, 'ABVSR005',
         'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_t3viu7hv31217etdttr373q527/-S897-FWEBP',
         'https://panini.com.br/batman-vs-robin-05')
), edicoes_alvo AS (
    SELECT
        edicao.id,
        substring(trim(edicao.numero) from '([0-9]+)\s*$')::integer AS numero_numerico
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) IN (
              hqhub_normalizar_titulo_serie('Batman Vs. Robin'),
              hqhub_normalizar_titulo_serie('Batman Vs Robin'),
              hqhub_normalizar_titulo_serie('Batman versus Robin')
          )
      AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
      AND coalesce(serie.ano_inicio, 2023) = 2023
      AND substring(trim(edicao.numero) from '([0-9]+)\s*$') IS NOT NULL
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    fonte_externa = 'PANINI',
    id_externo = coalesce(edicao.id_externo, capa.referencia),
    url_origem = capa.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM edicoes_alvo alvo
JOIN capas capa ON capa.numero = alvo.numero_numerico
WHERE edicao.id = alvo.id;

UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao
JOIN series serie ON serie.id = edicao.serie_id
JOIN editoras editora ON editora.id = serie.editora_id
WHERE item.edicao_id = edicao.id
  AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Batman Vs. Robin'),
          hqhub_normalizar_titulo_serie('Batman Vs Robin'),
          hqhub_normalizar_titulo_serie('Batman versus Robin')
      )
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND coalesce(serie.ano_inicio, 2023) = 2023
  AND edicao.url_capa IS NOT NULL;
