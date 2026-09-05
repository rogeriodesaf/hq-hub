-- Corrige a capa principal do cadastro usado na posição 64 do guia.
UPDATE edicoes edicao
SET url_capa = 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_a35k5s718t1hh0bp2gthfcmo3c/-S897-f.webp'
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
  AND coalesce(serie.volume, 1) = 3
  AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
      hqhub_normalizar_titulo_serie('Saga do Batman, A'),
      hqhub_normalizar_titulo_serie('A Saga do Batman')
  )
  AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('5');
