-- Capas oficiais Panini das duas edicoes finais de Batman: A Gargula de Gotham.
WITH capas(numero, sku, url_capa, url_origem) AS (
    VALUES
        (3, 'AGARG003',
         'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_9o40c7ovi5343dljtuo80hpu67/-S897-f.webp',
         'https://panini.com.br/batman-a-gargula-de-gotham-03-de-4'),
        (4, 'AGARG004',
         'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_lrv1lo4ff94vv4rcpnmrf1m96f/-S897-f.webp',
         'https://panini.com.br/batman-a-gargula-de-gotham-04-de-4')
), edicoes_alvo AS (
    SELECT edicao.id,
           substring(trim(edicao.numero) from '([0-9]+)\s*$')::integer AS numero_numerico
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) IN (
              hqhub_normalizar_titulo_serie('Batman: Gargula de Gotham'),
              hqhub_normalizar_titulo_serie('Batman: A Gargula de Gotham'),
              hqhub_normalizar_titulo_serie('Batman: Gargula de Gotham - Minisserie'),
              hqhub_normalizar_titulo_serie('Batman: A Gargula de Gotham - Minisserie')
          )
      AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
      AND substring(trim(edicao.numero) from '([0-9]+)\s*$') IS NOT NULL
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    fonte_externa = 'PANINI',
    id_externo = coalesce(edicao.id_externo, capa.sku),
    url_origem = capa.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM edicoes_alvo alvo
JOIN capas capa ON capa.numero = alvo.numero_numerico
WHERE edicao.id = alvo.id;
