UPDATE edicoes e
SET url_capa = 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_d3nhob1e1l0ml94v46dhtnqf09/-S265-FWEBP',
    data_atualizacao = CURRENT_TIMESTAMP
FROM series s
JOIN editoras p ON p.id = s.editora_id
WHERE e.serie_id = s.id
  AND lower(s.titulo) IN ('mulher-maravilha 1ª série', 'mulher-maravilha 1a série')
  AND lower(p.nome) LIKE '%panini%'
  AND COALESCE(s.volume, 1) = 1
  AND regexp_replace(e.numero, '^0+', '') = '46';
