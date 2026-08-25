-- Capa de Batman: Ano Dois - Edicao de Luxo (Panini, 2020).
WITH referencia AS (
    SELECT
        'https://rika.vtexassets.com/arquivos/ids/452701/https---www.artesequencial.com.br-imagens-herois_panini-batman-ano-dois-edicao-de-luxo.jpg?v=638472594492200000'::text AS url_capa,
        'https://www.rika.com.br/batman---ano-dois---edicao-de-luxo-15009408/p'::text AS url_origem
)
UPDATE edicoes edicao
SET url_capa = referencia.url_capa,
    fonte_externa = 'RIKA',
    url_origem = referencia.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM referencia, series serie, editoras editora
WHERE serie.id = edicao.serie_id
  AND editora.id = serie.editora_id
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
  AND (
      hqhub_normalizar_titulo_serie(edicao.titulo) IN (
          hqhub_normalizar_titulo_serie('Batman: Ano Dois - Edição de Luxo'),
          hqhub_normalizar_titulo_serie('Batman: Ano Dois'),
          hqhub_normalizar_titulo_serie('Batman - Ano Dois - Edição de Luxo')
      )
      OR hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Batman: Ano Dois - Edição de Luxo'),
          hqhub_normalizar_titulo_serie('Batman: Ano Dois'),
          hqhub_normalizar_titulo_serie('Batman - Ano Dois - Edição de Luxo')
      )
  );

UPDATE itens_ordem_leitura
SET url_capa_referencia =
        'https://rika.vtexassets.com/arquivos/ids/452701/https---www.artesequencial.com.br-imagens-herois_panini-batman-ano-dois-edicao-de-luxo.jpg?v=638472594492200000'
WHERE hqhub_normalizar_titulo_serie(titulo_referencia) =
      hqhub_normalizar_titulo_serie('Batman: Ano Dois');
