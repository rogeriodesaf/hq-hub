-- Capas oficiais Panini, numeros 1 a 11 de O Ultimo Dia das Bruxas.
WITH capas(numero, url_capa) AS (
    VALUES
        (1, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_al3o4j9t7p0d5arfanuc5v5h6e/-S897-FWEBP'),
        (2, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_9d5de14d451f1fmpt1u553e829/-S897-FWEBP'),
        (3, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_andakdgn6117hbode09jt96a5o/-S897-FWEBP'),
        (4, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_nmahia4irp371dq3cvg0va331q/-S897-FWEBP'),
        (5, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_3km4ebkl012t32l2fdb65hpr0k/-S897-FWEBP'),
        (6, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_om79jci2kp7k54vhp75e09ms52/-S897-FWEBP'),
        (7, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_lp7uro83k160h5nm7ssc6oem7a/-S897-FWEBP'),
        (8, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_qpvp4bjffp21d03ge98562293j/-S897-FWEBP'),
        (9, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_u2b0qa5n693sn9nc16n0irt426/-S897-FWEBP'),
        (10, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_sfr3f7aacd3ob7k3ej1v3p9l7d/-S897-FWEBP'),
        (11, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_4u18gd7rc513nee534ot8mev3p/-S897-FWEBP')
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    url_origem = 'https://panini.com.br/batman-o-ultimo-dia-das-bruxas-' || lpad(capa.numero::text, 2, '0'),
    data_atualizacao = CURRENT_TIMESTAMP
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
JOIN capas capa ON true
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
      hqhub_normalizar_titulo_serie('Batman: O Longo Dia das Bruxas - O Último Dia das Bruxas'),
      hqhub_normalizar_titulo_serie('Batman: O Último Dia das Bruxas'),
      hqhub_normalizar_titulo_serie('Batman: O Longo Dia das Bruxas - O Último Dia das Bruxas - Minissérie'),
      hqhub_normalizar_titulo_serie('Batman: O Último Dia das Bruxas - Minissérie')
  )
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND CASE WHEN trim(edicao.numero) ~ '^0*[0-9]+$'
           THEN trim(edicao.numero)::integer END = capa.numero
  AND edicao.url_capa IS DISTINCT FROM capa.url_capa;
