-- Capas das tres edicoes de Batman & Coringa: A Dupla Letal, Panini, V1.
-- Na edicao 1, usa a capa principal de Marc Silvestri, nao as variantes.
WITH capas(numero, url_capa, url_origem) AS (
    VALUES
        (1,
         'https://rika.vteximg.com.br/arquivos/ids/452745/https---www.artesequencial.com.br-imagens-herois_panini-batman-e-coringa-a-dupla-letal-1-capa-principal-por-marc-silvestri.jpg',
         'https://www.rika.com.br/batman-e-coringa---a-dupla-letal--1--capa-principal-por-marc-silvestri--15009430/p'),
        (2,
         'https://rika.vteximg.com.br/arquivos/ids/481694/15009434.jpg',
         'https://www.rika.com.br/batman-e-coringa---a-dupla-letal--2-15009434/p'),
        (3,
         'https://rika.vteximg.com.br/arquivos/ids/484561/https---www.artesequencial.com.br-imagens-sku-15010178.jpg',
         'https://www.rika.com.br/batman-e-coringa---a-dupla-letal--3-15010178/p')
), edicoes_alvo AS (
    SELECT edicao.id,
           substring(trim(edicao.numero) from '([0-9]+)\s*$')::integer AS numero_numerico
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) IN (
              hqhub_normalizar_titulo_serie('Batman & Coringa: A Dupla Letal'),
              hqhub_normalizar_titulo_serie('Batman e Coringa - A Dupla Letal')
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
JOIN capas capa ON capa.numero = alvo.numero_numerico
WHERE edicao.id = alvo.id;

UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao
JOIN series serie ON serie.id = edicao.serie_id
JOIN editoras editora ON editora.id = serie.editora_id
WHERE item.edicao_id = edicao.id
  AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Batman & Coringa: A Dupla Letal'),
          hqhub_normalizar_titulo_serie('Batman e Coringa - A Dupla Letal')
      )
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND serie.volume = 1
  AND edicao.url_capa IS NOT NULL;
