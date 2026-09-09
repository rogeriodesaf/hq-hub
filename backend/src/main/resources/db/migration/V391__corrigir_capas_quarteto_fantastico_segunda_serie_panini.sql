-- Capas corretas da Panini para Quarteto Fantástico - 2ª Série (2023-2026), volume 2.
WITH capas(numero, url_capa) AS (
    VALUES
    ('1', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_1d7hs4859d11h8jsranp5ti819/-S897-FWEBP'),
    ('2', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_0ils1fbifh0ktaekcu5h6aau7u/-S897-FWEBP'),
    ('3', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_c5417ehejh6h16dfjaub3h4i7k/-S897-FWEBP'),
    ('4', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_e35a9kc6qt1jp3h8qkodi4tq6j/-S897-FWEBP'),
    ('5', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_roq9gtcotp1374rp5urrbm6l40/-S897-FWEBP'),
    ('6', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_okn7eqvp8h4o99lf6ur0d7mj19/-S897-FWEBP')
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    data_atualizacao = CURRENT_TIMESTAMP
FROM capas capa, series serie, editoras editora
WHERE edicao.serie_id = serie.id
  AND serie.editora_id = editora.id
  AND hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('Quarteto Fantástico 2ª Série')
  AND serie.volume = 2
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND hqhub_normalizar_identidade(edicao.numero) = capa.numero;
