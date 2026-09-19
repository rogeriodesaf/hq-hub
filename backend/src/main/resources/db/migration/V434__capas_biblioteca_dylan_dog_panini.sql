-- Capas oficiais das duas edicoes cadastradas de Biblioteca Dylan Dog (Panini).
WITH capas(numero, url_capa, url_origem) AS (
    VALUES
        (
            1,
            'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_kdo5ldonq144d24atpkvs7nq1n/-S897-f.webp',
            'https://panini.com.br/dylan-dog-killex'
        ),
        (
            2,
            'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_85v5dds95l6nbcbtnjvcc38308/-S897-f.webp',
            'https://panini.com.br/dylan-dog-johnny-freak'
        )
)
UPDATE edicoes edicao
SET url_capa = capa.url_capa,
    url_origem = capa.url_origem,
    fonte_externa = 'PANINI',
    data_atualizacao = CURRENT_TIMESTAMP
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
JOIN capas capa ON true
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('Biblioteca Dylan Dog')
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND CASE WHEN trim(edicao.numero) ~ '^0*[0-9]+$'
           THEN trim(edicao.numero)::integer END = capa.numero
  AND edicao.url_capa IS DISTINCT FROM capa.url_capa;
