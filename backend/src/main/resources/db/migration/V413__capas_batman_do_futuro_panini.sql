-- Capas oficiais dos sete volumes de Batman do Futuro, Panini, V1.
WITH capas(numero, url_capa, url_origem) AS (
    VALUES
        (1,
         'https://panini.com.br/media/catalog/product/A/D/ADCHQ001.jpg',
         'https://panini.com.br/batman-do-futuro-vol-1'),
        (2,
         'https://panini.com.br/media/catalog/product/A/D/ADCHQ002.jpg',
         'https://panini.com.br/batman-do-futuro-vol-2'),
        (3,
         'https://panini.com.br/media/catalog/product/A/D/ADCHQ003.jpg',
         'https://panini.com.br/batman-do-futuro-vol-3'),
        (4,
         'https://panini.com.br/media/catalog/product/A/D/ADCHQ004.jpg',
         'https://panini.com.br/batman-do-futuro-vol-4'),
        (5,
         'https://panini.com.br/media/catalog/product/A/D/ADCHQ005.jpg',
         'https://panini.com.br/batman-do-futuro-vol-5'),
        (6,
         'https://panini.com.br/media/catalog/product/A/D/ADCHQ006.jpg',
         'https://panini.com.br/media/catalog/product/A/D/ADCHQ006.jpg'),
        (7,
         'https://panini.com.br/media/catalog/product/A/D/ADCHQ007.jpg',
         'https://panini.com.br/batman-do-futuro-vol-7-de-7')
), edicoes_alvo AS (
    SELECT edicao.id,
           substring(trim(edicao.numero) from '([0-9]+)\s*$')::integer AS numero_numerico
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Batman do Futuro')
      AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
      AND serie.volume = 1
      AND substring(trim(edicao.numero) from '([0-9]+)\s*$') IS NOT NULL
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    fonte_externa = 'PANINI',
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
      hqhub_normalizar_titulo_serie('Batman do Futuro')
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND serie.volume = 1
  AND edicao.url_capa IS NOT NULL;
