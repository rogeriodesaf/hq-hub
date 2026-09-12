-- Capas das oito edicoes de Batman - O Longo Dia das Bruxas - Minisserie,
-- publicada pela Abril (volume 1).
WITH capas(numero, url_capa, url_origem) AS (
    VALUES
        (1,
         'https://rika.vteximg.com.br/arquivos/ids/237621/-herois_abril_etc-batman-longo-dia-bru-01.jpg',
         'https://www.rika.com.br/batman---o-longo-dia-das-bruxas--116000790/p'),
        (2,
         'https://rika.vteximg.com.br/arquivos/ids/237622/-herois_abril_etc-batman-longo-dia-bru-02.jpg',
         'https://www.rika.com.br/batman---o-longo-dia-das-bruxas--216000791/p'),
        (3,
         'https://rika.vteximg.com.br/arquivos/ids/237623/-herois_abril_etc-batman-longo-dia-bru-03.jpg',
         'https://www.rika.com.br/batman---o-longo-dia-das-bruxas--316000792/p'),
        (4,
         'https://rika.vteximg.com.br/arquivos/ids/237624/-herois_abril_etc-batman-longo-dia-bru-04.jpg',
         'https://www.rika.com.br/batman---o-longo-dia-das-bruxas--416000793/p'),
        (5,
         'https://rika.vteximg.com.br/arquivos/ids/237625/-herois_abril_etc-batman-longo-dia-bru-05.jpg',
         'https://www.rika.com.br/batman---o-longo-dia-das-bruxas--516000794/p'),
        (6,
         'https://rika.vteximg.com.br/arquivos/ids/237626/-herois_abril_etc-batman-longo-dia-bru-06.jpg',
         'https://www.rika.com.br/batman---o-longo-dia-das-bruxas--616000795/p'),
        (7,
         'https://rika.vteximg.com.br/arquivos/ids/237627/-herois_abril_etc-batman-longo-dia-bru-07.jpg',
         'https://www.rika.com.br/batman---o-longo-dia-das-bruxas--716000796/p'),
        (8,
         'https://rika.vteximg.com.br/arquivos/ids/237628/-herois_abril_etc-batman-longo-dia-bru-08.jpg',
         'https://www.rika.com.br/batman---o-longo-dia-das-bruxas--816000797/p')
), edicoes_alvo AS (
    SELECT edicao.id,
           substring(trim(edicao.numero) from '([0-9]+)\s*$')::integer AS numero_numerico
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Batman - O Longo Dia das Bruxas - Minisserie')
      AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%abril%'
      AND serie.volume = 1
      AND substring(trim(edicao.numero) from '([0-9]+)\s*$') IS NOT NULL
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    fonte_externa = 'RIKA',
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
  AND hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('Batman - O Longo Dia das Bruxas - Minisserie')
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%abril%'
  AND serie.volume = 1
  AND edicao.url_capa IS NOT NULL;
