-- Capa oficial de Batman/Dylan Dog: A Sombra do Morcego, Panini, 2024.
UPDATE edicoes edicao
SET url_capa = 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_qcv28fbhi156d8pqiosf39d97h/-S897-FWEBP',
    fonte_externa = 'PANINI',
    id_externo = coalesce(edicao.id_externo, 'ADBON001'),
    url_origem = 'https://panini.com.br/batman-dylan-dog-dc-bonelli',
    data_atualizacao = CURRENT_TIMESTAMP
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND coalesce(serie.ano_inicio, 2024) = 2024
  AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
      hqhub_normalizar_titulo_serie('Batman/Dylan Dog'),
      hqhub_normalizar_titulo_serie('Batman & Dylan Dog'),
      hqhub_normalizar_titulo_serie('Batman/Dylan Dog: A Sombra do Morcego'),
      hqhub_normalizar_titulo_serie('Batman e Dylan Dog: A Sombra do Morcego')
  );

UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao
JOIN series serie ON serie.id = edicao.serie_id
JOIN editoras editora ON editora.id = serie.editora_id
WHERE item.edicao_id = edicao.id
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND coalesce(serie.ano_inicio, 2024) = 2024
  AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
      hqhub_normalizar_titulo_serie('Batman/Dylan Dog'),
      hqhub_normalizar_titulo_serie('Batman & Dylan Dog'),
      hqhub_normalizar_titulo_serie('Batman/Dylan Dog: A Sombra do Morcego'),
      hqhub_normalizar_titulo_serie('Batman e Dylan Dog: A Sombra do Morcego')
  )
  AND edicao.url_capa IS NOT NULL;
