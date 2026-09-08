-- Capas oficiais da Panini para A Saga de Thanos (2019-2020), volume 1.
WITH capas(numero, url_capa) AS (
    VALUES
    ('1', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_q6np23va917qt6go1a8pd80952/-S897-FWEBP'),
    ('2', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_26bb2qe7s150vd9nlb2ream21d/-S897-FWEBP')
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    data_atualizacao = CURRENT_TIMESTAMP
FROM capas capa, series serie, editoras editora
WHERE edicao.serie_id = serie.id
  AND serie.editora_id = editora.id
  AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
      hqhub_normalizar_titulo_serie('A Saga de Thanos'),
      hqhub_normalizar_titulo_serie('Marvel Deluxe: A Saga de Thanos')
  )
  AND COALESCE(serie.volume, 1) = 1
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND hqhub_normalizar_identidade(edicao.numero) = capa.numero;
