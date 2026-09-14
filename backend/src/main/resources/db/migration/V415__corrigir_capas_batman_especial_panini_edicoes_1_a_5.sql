-- Substitui as capas incorretas dos cinco primeiros volumes de Batman Especial
-- pelas imagens correspondentes a cada publicacao da primeira serie da Panini.
WITH capas(numero, titulo, referencia, url_capa, url_origem) AS (VALUES
    ('1', 'Cidade do Bane',
     'ABATE001',
     'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_20b6e5k6gh7ehb8u6b52ln9i52/-S265-FWEBP',
     'https://panini.com.br/batman-especial-vol-1-cidade-do-bane'),
    ('2', 'Coringa - Aniversário de 80 Anos',
     'ABATE002',
     'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_8nc3f2q7op38t1qbsr4bo4ga1l/-S265-FWEBP',
     'https://panini.com.br/batman-especial-vol-2-coringa-aniversario-de-80-anos'),
    ('3', 'Robin - Aniversário de 80 Anos',
     'ABATE003',
     'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_5q1m4kfm9p1kd5tm7aetpann49/-S265-FWEBP',
     'https://panini.com.br/batman-especial-vol-3-robin-aniversario-de-80-anos'),
    ('4', 'Mulher-Gato - Aniversário de 80 Anos',
     'ABATE004',
     'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_ap7qgqno9p37rasmtifhu22l39/-S265-FWEBP',
     'https://panini.com.br/batman-especial-vol-4-mulher-gato-aniversario-de-80-anos'),
    ('5', 'Lendas Urbanas: Capuz Vermelho',
     'ABATE005',
     'https://rika.vteximg.com.br/arquivos/ids/452684/batman-especial-05-lendas-urbanas-capuz-vermelho.jpg?v=638470777022170000',
     'https://www.rika.com.br/batman-especial--5---lendas-urbanas---capuz-vermelho-15008303/p')
), serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
      AND coalesce(serie.volume, 0) = 1
      AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Batman Especial'),
          hqhub_normalizar_titulo_serie('Batman Especial 1ª Série')
      )
    ORDER BY
        (hqhub_normalizar_titulo_serie(serie.titulo) =
         hqhub_normalizar_titulo_serie('Batman Especial')) DESC,
        serie.id
    LIMIT 1
)
UPDATE edicoes edicao
SET titulo = capa.titulo,
    nome_volume = capa.titulo,
    url_capa = capa.url_capa,
    fonte_externa = 'PANINI',
    id_externo = capa.referencia,
    url_origem = capa.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_alvo serie
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_identidade(edicao.numero) =
      hqhub_normalizar_identidade(capa.numero);

UPDATE itens_ordem_leitura item
SET url_capa_referencia = edicao.url_capa
FROM edicoes edicao
JOIN series serie ON serie.id = edicao.serie_id
JOIN editoras editora ON editora.id = serie.editora_id
WHERE item.edicao_id = edicao.id
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND coalesce(serie.volume, 0) = 1
  AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
      hqhub_normalizar_titulo_serie('Batman Especial'),
      hqhub_normalizar_titulo_serie('Batman Especial 1ª Série')
  )
  AND hqhub_normalizar_identidade(edicao.numero) IN ('1', '2', '3', '4', '5');
