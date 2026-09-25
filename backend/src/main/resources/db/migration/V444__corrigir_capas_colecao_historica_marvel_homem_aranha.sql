-- Colecao Historica Marvel: O Homem-Aranha, Panini, volume 1 (2013-2015).
-- As 12 capas foram conferidas pela numeracao nos produtos da Rika Comic Shop.
WITH capas(numero, url_capa, url_origem) AS (
    VALUES
        (1, 'https://rika.vtexassets.com/arquivos/ids/223309',
         'https://www.rika.com.br/colecao-historica-marvel---homem-aranha--115003517/p'),
        (2, 'https://rika.vtexassets.com/arquivos/ids/223313',
         'https://www.rika.com.br/colecao-historica-marvel---homem-aranha--215003518/p'),
        (3, 'https://rika.vtexassets.com/arquivos/ids/223314',
         'https://www.rika.com.br/colecao-historica-marvel---homem-aranha--315003519/p'),
        (4, 'https://rika.vtexassets.com/arquivos/ids/223315',
         'https://www.rika.com.br/colecao-historica-marvel---homem-aranha--415003520/p'),
        (5, 'https://rika.vtexassets.com/arquivos/ids/270914',
         'https://www.rika.com.br/colecao-historica-marvel---homem-aranha--515003759/p'),
        (6, 'https://rika.vtexassets.com/arquivos/ids/270915',
         'https://www.rika.com.br/colecao-historica-marvel---homem-aranha--615003760/p'),
        (7, 'https://rika.vtexassets.com/arquivos/ids/270916',
         'https://www.rika.com.br/colecao-historica-marvel---homem-aranha--715003761/p'),
        (8, 'https://rika.vtexassets.com/arquivos/ids/270917',
         'https://www.rika.com.br/colecao-historica-marvel---homem-aranha--815003762/p'),
        (9, 'https://rika.vtexassets.com/arquivos/ids/278634',
         'https://www.rika.com.br/colecao-historica-marvel---homem-aranha--0915004357/p'),
        (10, 'https://rika.vtexassets.com/arquivos/ids/278633',
         'https://www.rika.com.br/colecao-historica-marvel---homem-aranha--1015004356/p'),
        (11, 'https://rika.vtexassets.com/arquivos/ids/284074',
         'https://www.rika.com.br/colecao-historica-marvel---homem-aranha--1115004832/p'),
        (12, 'https://rika.vtexassets.com/arquivos/ids/284075',
         'https://www.rika.com.br/colecao-historica-marvel---homem-aranha--1215004833/p')
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
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE
      hqhub_normalizar_titulo_serie('Panini') || '%'
  AND coalesce(serie.volume, 1) = 1
  AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
      hqhub_normalizar_titulo_serie('Coleção Histórica Marvel: O Homem-Aranha'),
      hqhub_normalizar_titulo_serie('Coleção Histórica Marvel - Homem-Aranha'),
      hqhub_normalizar_titulo_serie('Coleção Histórica Marvel: Homem-Aranha'),
      hqhub_normalizar_titulo_serie('Coleção Histórica Marvel Homem Aranha'))
  AND CASE WHEN trim(edicao.numero) ~ '^0*[0-9]+$'
           THEN trim(edicao.numero)::integer END = capa.numero
  AND (edicao.url_capa IS DISTINCT FROM capa.url_capa
       OR edicao.url_origem IS DISTINCT FROM capa.url_origem);
