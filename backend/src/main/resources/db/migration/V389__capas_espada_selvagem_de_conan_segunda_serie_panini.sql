-- Capas oficiais da Panini para Espada Selvagem de Conan, A 2ª Série (2024-), volume 2.
WITH capas(numero, url_capa) AS (
    VALUES
    ('1', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_3fo2153a7t7ol0rqcm5n31av5j/-S897-FWEBP'),
    ('2', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_rtl0c0irod6nb0of4490815l33/-S897-FWEBP'),
    ('3', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_rd6u2c50tt3in02sm6mmdc2r5c/-S897-FWEBP'),
    ('4', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_adn165eg392sf4iln3roti2m13/-S897-FWEBP'),
    ('5', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_ol31bn00c50kp70hlrfn29vd13/-S897-FWEBP')
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    data_atualizacao = CURRENT_TIMESTAMP
FROM capas capa, series serie, editoras editora
WHERE edicao.serie_id = serie.id
  AND serie.editora_id = editora.id
  AND hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('Espada Selvagem de Conan, A 2ª Série')
  AND serie.volume = 2
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND hqhub_normalizar_identidade(edicao.numero) = capa.numero;
