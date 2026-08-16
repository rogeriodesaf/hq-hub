-- Capas brasileiras das nove edições de Guerras Secretas V2 (Panini).

WITH capas(numero, url_capa) AS (VALUES
    (1, 'https://rika.vtexassets.com/arquivos/ids/284198/guerras-secretas-01.jpg'),
    (2, 'https://rika.vtexassets.com/arquivos/ids/288072/guerras-secretas-02.jpg'),
    (3, 'https://rika.vtexassets.com/arquivos/ids/340478/Guerras-Secretas-3.jpg'),
    (4, 'https://rika.vtexassets.com/arquivos/ids/340479/Guerras-Secretas-4.jpg'),
    (5, 'https://rika.vtexassets.com/arquivos/ids/340480/Guerras-Secretas-5.jpg'),
    (6, 'https://rika.vtexassets.com/arquivos/ids/340481/Guerras-Secretas-6.jpg'),
    (7, 'https://rika.vtexassets.com/arquivos/ids/340482/Guerras-Secretas-7.jpg'),
    (8, 'https://rika.vtexassets.com/arquivos/ids/340483/Guerras-Secretas-8.jpg'),
    (9, 'https://rika.vtexassets.com/arquivos/ids/340484/Guerras-Secretas-9.jpg')
)
UPDATE itens_ordem_leitura item
SET url_capa_referencia = capa.url_capa
FROM capas capa
WHERE lower(trim(item.titulo_referencia)) = lower('Guerras Secretas')
  AND lower(trim(item.detalhe_referencia)) = lower('V2 #' || capa.numero);

WITH capas(numero, url_capa, url_origem) AS (VALUES
    (1, 'https://rika.vtexassets.com/arquivos/ids/284198/guerras-secretas-01.jpg', 'https://www.rika.com.br/guerras-secretas--115004956/p'),
    (2, 'https://rika.vtexassets.com/arquivos/ids/288072/guerras-secretas-02.jpg', 'https://www.rika.com.br/guerras-secretas--215004958/p'),
    (3, 'https://rika.vtexassets.com/arquivos/ids/340478/Guerras-Secretas-3.jpg', 'https://www.rika.com.br/guerras-secretas--315004960/p'),
    (4, 'https://rika.vtexassets.com/arquivos/ids/340479/Guerras-Secretas-4.jpg', 'https://www.rika.com.br/guerras-secretas--415004962/p'),
    (5, 'https://rika.vtexassets.com/arquivos/ids/340480/Guerras-Secretas-5.jpg', 'https://www.rika.com.br/guerras-secretas--515004964/p'),
    (6, 'https://rika.vtexassets.com/arquivos/ids/340481/Guerras-Secretas-6.jpg', 'https://www.rika.com.br/guerras-secretas--615004966/p'),
    (7, 'https://rika.vtexassets.com/arquivos/ids/340482/Guerras-Secretas-7.jpg', 'https://www.rika.com.br/guerras-secretas--715004968/p'),
    (8, 'https://rika.vtexassets.com/arquivos/ids/340483/Guerras-Secretas-8.jpg', 'https://www.rika.com.br/guerras-secretas--815004970/p'),
    (9, 'https://rika.vtexassets.com/arquivos/ids/340484/Guerras-Secretas-9.jpg', 'https://www.rika.com.br/guerras-secretas--915004972/p')
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    url_origem = capa.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM capas capa, series serie, editoras editora
WHERE edicao.serie_id = serie.id
  AND serie.editora_id = editora.id
  AND lower(trim(editora.nome)) = lower('Panini')
  AND lower(trim(serie.titulo)) = lower('Guerras Secretas')
  AND substring(edicao.numero FROM '([0-9]+)')::integer = capa.numero;
