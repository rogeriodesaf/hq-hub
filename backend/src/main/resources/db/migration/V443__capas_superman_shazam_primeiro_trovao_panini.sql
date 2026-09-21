-- Superman & Shazam! - O Primeiro Trovao, minisserie Panini de 2006.
-- As capas 1 de 2 e 2 de 2 foram conferidas visualmente nos produtos Rika.
WITH capas(numero, url_capa, url_origem) AS (
    VALUES
        (1, 'https://rika.vtexassets.com/arquivos/ids/220663',
         'https://www.rika.com.br/superman-e-shazam---primeiro-trovao--115000850/p'),
        (2, 'https://rika.vtexassets.com/arquivos/ids/220664',
         'https://www.rika.com.br/superman-e-shazam---primeiro-trovao--215000851/p')
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    url_origem = capa.url_origem,
    fonte_externa = 'RIKA',
    data_atualizacao = CURRENT_TIMESTAMP
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
JOIN capas capa ON true
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND coalesce(serie.volume, 1) = 1
  AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
      hqhub_normalizar_titulo_serie('Superman & Shazam! - O Primeiro Trovão'),
      hqhub_normalizar_titulo_serie('Superman & Shazam! - O Primeiro Trovão — Minissérie'),
      hqhub_normalizar_titulo_serie('Superman e Shazam! - O Primeiro Trovão'),
      hqhub_normalizar_titulo_serie('Superman e Shazam! - O Primeiro Trovão — Minissérie'))
  AND CASE WHEN trim(edicao.numero) ~ '^0*[0-9]+$'
           THEN trim(edicao.numero)::integer END = capa.numero
  AND (edicao.url_capa IS DISTINCT FROM capa.url_capa
       OR edicao.url_origem IS DISTINCT FROM capa.url_origem);
