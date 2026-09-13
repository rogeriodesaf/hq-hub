-- Capa oficial de Batman & The Spirit #1, edicao brasileira da Panini (V1).
WITH capa(numero, url_capa, url_origem) AS (
    VALUES
        (1,
         'https://static.dc.com/dc/files/default_images/bm_spirit_5ba0371e70d327.17898445.jpg',
         'https://www.dc.com/comics/batman/the-spirit-2007/batman/the-spirit-1')
), edicoes_alvo AS (
    SELECT edicao.id,
           substring(trim(edicao.numero) from '([0-9]+)\s*$')::integer AS numero_numerico
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) IN (
              hqhub_normalizar_titulo_serie('Batman & The Spirit'),
              hqhub_normalizar_titulo_serie('Batman e The Spirit')
          )
      AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
      AND serie.volume = 1
      AND substring(trim(edicao.numero) from '([0-9]+)\s*$') IS NOT NULL
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    fonte_externa = 'DC',
    url_origem = capa.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM edicoes_alvo alvo
JOIN capa ON capa.numero = alvo.numero_numerico
WHERE edicao.id = alvo.id;

UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao
JOIN series serie ON serie.id = edicao.serie_id
JOIN editoras editora ON editora.id = serie.editora_id
WHERE item.edicao_id = edicao.id
  AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Batman & The Spirit'),
          hqhub_normalizar_titulo_serie('Batman e The Spirit')
      )
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND serie.volume = 1
  AND edicao.url_capa IS NOT NULL;
