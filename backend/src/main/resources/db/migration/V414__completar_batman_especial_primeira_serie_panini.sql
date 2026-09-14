-- Completa Batman Especial (1a serie, Panini) com os volumes 6 a 13.
-- As cinco primeiras edicoes ja haviam sido cadastradas pelo importador.
WITH dados(numero, titulo, data_publicacao, paginas, preco, referencia, url_capa, url_origem) AS (VALUES
    ('6',  'Lendas Urbanas: Bandoleiro',                    DATE '2022-03-31', 128, 32.90, 'ABATE006', 'https://img.assinaja.com/assets/tZ/099/img/382421_900x900.png', 'https://mundosinfinitos.com.br/geek/produto/Comics-DC-Batman-Especial-vol-06-Lendas-Urbanas-Bandoleiro-117437.aspx'),
    ('7',  'Caçador de Palhaços & Criador de Fantasmas',   DATE '2022-05-13', 152, 36.90, 'ABATE007', 'https://www.comix.com.br/media/catalog/product/cache/6525f4433975e88c1411adaa06624960/4/1/414537_900x900.png', 'https://www.comix.com.br/batman-especial-vol-7-cacador-de-palhacos.html'),
    ('8',  'Os Vilões de Gotham',                          DATE '2022-07-01', 128, 32.90, 'ABATE008', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_e1d7ck5vsh79n6k1gmqusjaf0l/-S265-FWEBP', 'https://panini.com.br/batman-especial-vol-8-os-viloes-de-gotham'),
    ('9',  'Corporação Exterminador',                       DATE '2022-09-01', 208, 57.90, 'ABATE009', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_478bet9nop4n3113qd7vm2hs4l/-S265-FWEBP', 'https://panini.com.br/batman-especial-vol-9-corporacao-exterminador'),
    ('10', 'Robin Tim Drake e os Renegados',                DATE '2022-12-01', 144, 36.90, 'ABATE010', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_7h2poisfm93it3rn5ke6ejqq12/-S265-FWEBP', 'https://panini.com.br/batman-especial-vol-10-robin-tim-drake-e-os-renegados'),
    ('11', 'Eu Sou Batman - Parte 1',                       DATE '2023-03-01', 144, 39.90, 'ABATE011', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_5mpjm22pe13unbui1nkvtd0i5s/-S265-FWEBP', 'https://panini.com.br/batman-especial-vol-11-eu-sou-batman'),
    ('12', 'Eu Sou Batman - Parte 2',                       DATE '2023-07-01', 128, 34.90, 'ABATE012', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_1fsk7abngt14hc7cc7v906ts5f/-S265-FWEBP', 'https://panini.com.br/batman-especial-vol-12-eu-sou-batman'),
    ('13', 'Eu Sou o Batman - Parte 3',                     DATE '2023-09-01', 148, 39.90, 'ABATE013', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_vklkhbmfal05j9b1r4repqud6t/-S265-FWEBP', 'https://panini.com.br/batman-especial-vol-13-eu-sou-o-batman')
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
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    quantidade_paginas, preco_capa, formato, fonte_externa, id_externo,
    url_origem, serie_id, data_criacao, data_atualizacao
)
SELECT
    dado.numero,
    dado.titulo,
    'Volume ' || dado.numero || ' de Batman Especial, primeira série da Panini.',
    dado.titulo,
    dado.data_publicacao,
    dado.url_capa,
    dado.paginas,
    dado.preco,
    '17 x 26 cm, capa cartão, lombada quadrada',
    'PANINI',
    dado.referencia,
    dado.url_origem,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM dados dado
CROSS JOIN serie_alvo serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    nome_volume = EXCLUDED.nome_volume,
    data_publicacao = EXCLUDED.data_publicacao,
    url_capa = EXCLUDED.url_capa,
    quantidade_paginas = EXCLUDED.quantidade_paginas,
    preco_capa = EXCLUDED.preco_capa,
    formato = EXCLUDED.formato,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

UPDATE series serie
SET ano_fim = 2023,
    data_atualizacao = CURRENT_TIMESTAMP
FROM editoras editora
WHERE editora.id = serie.editora_id
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND coalesce(serie.volume, 0) = 1
  AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
      hqhub_normalizar_titulo_serie('Batman Especial'),
      hqhub_normalizar_titulo_serie('Batman Especial 1ª Série')
  );
