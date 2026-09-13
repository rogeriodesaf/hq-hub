-- Capa da edicao unica Batman & Mulher-Gato - Rastro de Polvora,
-- publicada pela Panini (volume 1).
WITH capa(numero, url_capa, url_origem) AS (
    VALUES
        (1,
         'https://rika.vteximg.com.br/arquivos/ids/220320/-herois_panini-batman-mul-gato-rastro-01.jpg',
         'https://www.rika.com.br/batman-e-mulher-gato---rastro-de-polvora--115000497/p')
), edicoes_alvo AS (
    SELECT edicao.id,
           substring(trim(edicao.numero) from '([0-9]+)\s*$')::integer AS numero_numerico
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) IN (
              hqhub_normalizar_titulo_serie('Batman & Mulher-Gato - Rastro de Polvora'),
              hqhub_normalizar_titulo_serie('Batman e Mulher-Gato - Rastro de Polvora')
          )
      AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
      AND serie.volume = 1
      AND substring(trim(edicao.numero) from '([0-9]+)\s*$') IS NOT NULL
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    fonte_externa = 'RIKA',
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
          hqhub_normalizar_titulo_serie('Batman & Mulher-Gato - Rastro de Polvora'),
          hqhub_normalizar_titulo_serie('Batman e Mulher-Gato - Rastro de Polvora')
      )
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND serie.volume = 1
  AND edicao.url_capa IS NOT NULL;
