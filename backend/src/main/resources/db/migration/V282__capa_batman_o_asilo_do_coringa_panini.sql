-- Capa oficial da edicao brasileira Batman: O Asilo do Coringa (Panini, 2024).
WITH referencia AS (
    SELECT
        'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_vfdc1ro3ap4091ks4pkcjuu445/-S897-f.webp'::text AS url_capa,
        'https://panini.com.br/o-asilo-do-coringa'::text AS url_origem
)
UPDATE edicoes edicao
SET url_capa = referencia.url_capa,
    fonte_externa = 'PANINI',
    url_origem = referencia.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM referencia, series serie, editoras editora
WHERE serie.id = edicao.serie_id
  AND editora.id = serie.editora_id
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
  AND (
      hqhub_normalizar_titulo_serie(edicao.titulo) IN (
          hqhub_normalizar_titulo_serie('Batman: O Asilo do Coringa'),
          hqhub_normalizar_titulo_serie('O Asilo do Coringa')
      )
      OR hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Batman: O Asilo do Coringa'),
          hqhub_normalizar_titulo_serie('O Asilo do Coringa')
      )
  );

UPDATE itens_ordem_leitura
SET url_capa_referencia =
        'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_vfdc1ro3ap4091ks4pkcjuu445/-S897-f.webp'
WHERE hqhub_normalizar_titulo_serie(titulo_referencia) =
      hqhub_normalizar_titulo_serie('Batman: O Asilo do Coringa');
