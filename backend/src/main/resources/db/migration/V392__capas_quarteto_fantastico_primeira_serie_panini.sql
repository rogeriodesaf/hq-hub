-- Capas da Panini para Quarteto Fantástico - 1ª Série (2019-2023), volume 1.
WITH capas(numero, url_capa) AS (
    VALUES
    ('1', 'https://panini.com.br/media/catalog/product/A/M/AMVKW001.jpg'),
    ('2', 'https://panini.com.br/media/catalog/product/A/M/AMVKW002.jpg'),
    ('3', 'https://panini.com.br/media/catalog/product/A/M/AMVKW003.jpg'),
    ('4', 'https://panini.com.br/media/catalog/product/A/M/AMVKW004.jpg'),
    ('5', 'https://panini.com.br/media/catalog/product/A/M/AMVKW005.jpg'),
    ('6', 'https://panini.com.br/media/catalog/product/A/M/AMVKW006.jpg'),
    ('7', 'https://panini.com.br/media/catalog/product/A/M/AMVKW007.jpg'),
    ('8', 'https://panini.com.br/media/catalog/product/A/M/AMVKW008.jpg'),
    ('9', 'https://panini.com.br/media/catalog/product/A/M/AMVKW009.jpg'),
    ('10', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_kit12fu3b10u5cgvivq7ll3715/-S897-FWEBP'),
    ('11', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_auk5kvobp97ojfa6qdpo1vg85o/-S897-FWEBP')
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    data_atualizacao = CURRENT_TIMESTAMP
FROM capas capa, series serie, editoras editora
WHERE edicao.serie_id = serie.id
  AND serie.editora_id = editora.id
  AND hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('Quarteto Fantástico 1ª Série')
  AND COALESCE(serie.volume, 1) = 1
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND hqhub_normalizar_identidade(edicao.numero) = capa.numero;
