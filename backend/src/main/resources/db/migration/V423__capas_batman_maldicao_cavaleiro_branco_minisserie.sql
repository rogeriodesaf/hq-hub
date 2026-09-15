-- Capas das nove edicoes de Batman: A Maldicao do Cavaleiro Branco, Panini, 2020.
WITH capas(numero, sku, url_capa, url_origem) AS (
    VALUES
        (1, '15007804',
         'https://rika.vteximg.com.br/arquivos/ids/418853/https---www.artesequencial.com.br-imagens-bruno-batman-a-maldicao-do-cavaleiro-branco-1.jpg?v=638006655385200000',
         'https://www.rika.com.br/batman---a-maldicao-do-cavaleiro-branco--1-15007804/p'),
        (2, '15007805',
         'https://rika.vteximg.com.br/arquivos/ids/418855/https---www.artesequencial.com.br-imagens-bruno-batman-a-maldicao-do-cavaleiro-branco-2.jpg?v=638006655411370000',
         'https://www.rika.com.br/batman---a-maldicao-do-cavaleiro-branco--2-15007805/p'),
        (3, '15007806',
         'https://rika.vteximg.com.br/arquivos/ids/406536/Batman-A-Maldicao-do-Cavaleiro-Branco-3.jpg?v=637598295095800000',
         'https://www.rika.com.br/batman---a-maldicao-do-cavaleiro-branco--3-15007806/p'),
        (4, '15007807',
         'https://rika.vteximg.com.br/arquivos/ids/406537/Batman-A-Maldicao-do-Cavaleiro-Branco-4.jpg?v=637598295106300000',
         'https://www.rika.com.br/batman---a-maldicao-do-cavaleiro-branco--4-15007807/p'),
        (5, '15007808',
         'https://rika.vteximg.com.br/arquivos/ids/406538/Batman-A-Maldicao-do-Cavaleiro-Branco-5.jpg?v=637598295116130000',
         'https://www.rika.com.br/batman---a-maldicao-do-cavaleiro-branco--5-15007808/p'),
        (6, '15007809',
         'https://rika.vteximg.com.br/arquivos/ids/406539/Batman-A-Maldicao-do-Cavaleiro-Branco-6.jpg?v=637598295125730000',
         'https://www.rika.com.br/batman---a-maldicao-do-cavaleiro-branco--6-15007809/p'),
        (7, '15007810',
         'https://rika.vteximg.com.br/arquivos/ids/479334/15007810.jpg?v=638724747639970000',
         'https://www.rika.com.br/batman---a-maldicao-do-cavaleiro-branco--7-15007810/p'),
        (8, '15007811',
         'https://rika.vteximg.com.br/arquivos/ids/406541/Batman-A-Maldicao-do-Cavaleiro-Branco-8.jpg?v=637598295143900000',
         'https://www.rika.com.br/batman---a-maldicao-do-cavaleiro-branco--8-15007811/p'),
        (9, '15007812',
         'https://rika.vteximg.com.br/arquivos/ids/406542/Batman-A-Maldicao-do-Cavaleiro-Branco-9.jpg?v=637598295153900000',
         'https://www.rika.com.br/batman---a-maldicao-do-cavaleiro-branco--9-15007812/p')
), edicoes_alvo AS (
    SELECT edicao.id,
           substring(trim(edicao.numero) from '([0-9]+)\s*$')::integer AS numero_numerico
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) IN (
              hqhub_normalizar_titulo_serie('Batman: A Maldicao do Cavaleiro Branco'),
              hqhub_normalizar_titulo_serie('Batman: A Maldicao do Cavaleiro Branco - Minisserie')
          )
      AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
      AND coalesce(serie.volume, 1) = 1
      AND coalesce(serie.ano_inicio, 2020) = 2020
      AND substring(trim(edicao.numero) from '([0-9]+)\s*$') IS NOT NULL
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    fonte_externa = 'RIKA',
    id_externo = coalesce(edicao.id_externo, capa.sku),
    url_origem = capa.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM edicoes_alvo alvo
JOIN capas capa ON capa.numero = alvo.numero_numerico
WHERE edicao.id = alvo.id;

UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao
JOIN series serie ON serie.id = edicao.serie_id
JOIN editoras editora ON editora.id = serie.editora_id
WHERE item.edicao_id = edicao.id
  AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Batman: A Maldicao do Cavaleiro Branco'),
          hqhub_normalizar_titulo_serie('Batman: A Maldicao do Cavaleiro Branco - Minisserie')
      )
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND coalesce(serie.ano_inicio, 2020) = 2020
  AND edicao.url_capa IS NOT NULL;
