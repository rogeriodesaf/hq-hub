-- Capas brasileiras conferidas por titulo, editora e numero da edicao.
-- Superman - Terra Um: os tres volumes da Panini, em suas primeiras edicoes.
-- Superman & Batman - As Duas Faces da Justica: minisserie da Abril (2002).
WITH capas(titulo, editora, numero, url_capa, url_origem) AS (
    VALUES
        ('Superman - Terra Um', 'Panini', 1,
         'https://rika.vtexassets.com/arquivos/ids/223379',
         'https://www.rika.com.br/superman---terra-um15003577/p'),
        ('Superman - Terra Um', 'Panini', 2,
         'https://rika.vtexassets.com/arquivos/ids/278886',
         'https://www.rika.com.br/superman---terra-um---volume-215004609/p'),
        ('Superman - Terra Um', 'Panini', 3,
         'https://rika.vtexassets.com/arquivos/ids/345804',
         'https://www.rika.com.br/superman---terra-um---volume-3-15007348/p'),
        ('Superman & Batman - As Duas Faces da Justiça', 'Abril', 1,
         'https://rika.vtexassets.com/arquivos/ids/237337',
         'https://www.rika.com.br/superman-e-batman---as-duas-faces-da-justica--116001589/p'),
        ('Superman & Batman - As Duas Faces da Justiça', 'Abril', 2,
         'https://rika.vtexassets.com/arquivos/ids/237338',
         'https://www.rika.com.br/superman-e-batman---as-duas-faces-da-justica--216001590/p'),
        ('Superman & Batman - As Duas Faces da Justiça', 'Abril', 3,
         'https://rika.vtexassets.com/arquivos/ids/237339',
         'https://www.rika.com.br/superman-e-batman---as-duas-faces-da-justica--316001591/p')
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    url_origem = capa.url_origem,
    fonte_externa = 'RIKA',
    data_atualizacao = CURRENT_TIMESTAMP
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
JOIN capas capa ON hqhub_normalizar_titulo_serie(editora.nome) =
                   hqhub_normalizar_titulo_serie(capa.editora)
WHERE edicao.serie_id = serie.id
  AND (
      (hqhub_normalizar_titulo_serie(capa.titulo) = hqhub_normalizar_titulo_serie('Superman - Terra Um')
       AND hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie(capa.titulo)
       AND coalesce(serie.volume, 1) = 1)
      OR
      (hqhub_normalizar_titulo_serie(capa.titulo) =
           hqhub_normalizar_titulo_serie('Superman & Batman - As Duas Faces da Justiça')
       AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
           hqhub_normalizar_titulo_serie(capa.titulo),
           hqhub_normalizar_titulo_serie(capa.titulo || ' — Minissérie')))
  )
  AND CASE WHEN trim(edicao.numero) ~ '^0*[0-9]+$'
           THEN trim(edicao.numero)::integer END = capa.numero
  AND (edicao.url_capa IS DISTINCT FROM capa.url_capa
       OR edicao.url_origem IS DISTINCT FROM capa.url_origem);
