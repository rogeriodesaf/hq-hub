-- Cadastra os cinco volumes brasileiros de Vingadores Por Mark Waid.
-- Capas obtidas diretamente dos arquivos públicos da Panini.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini', 'Editora de quadrinhos e coleções.', 'Itália', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Vingadores Por Mark Waid',
    'Fase dos Vingadores escrita por Mark Waid, publicada no Brasil pela Panini em cinco volumes de capa dura.',
    1,
    'PANINI',
    'vingadores-por-mark-waid-panini-volume-1',
    'https://panini.com.br/vingadores-por-mark-waid-vol-5',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
ORDER BY editora.id
LIMIT 1
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO UPDATE SET
    descricao = EXCLUDED.descricao,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    tipo_serie = 'BRASILEIRA',
    data_atualizacao = CURRENT_TIMESTAMP;

WITH capas(numero, subtitulo, data_publicacao, url_capa) AS (VALUES
    ('1', 'Sete Heróis e Um Destino', DATE '2021-12-01', 'https://panini.com.br/media/catalog/product/A/V/AVINO001.jpg'),
    ('2', 'Vingadores Por Mark Waid - Volume 2', DATE '2022-08-01', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_1lc3pp6b9p6effna3pj0bg230h/-S897-f.webp'),
    ('3', 'Vingadores Por Mark Waid - Volume 3', DATE '2022-12-01', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_7p87bk1s097br7qins8kkt5u4e/-S897-f.webp'),
    ('4', 'Império Secreto', DATE '2023-09-01', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_0dr77ohog90fv1an6bn8t5ea2o/-S897-f.webp'),
    ('5', 'Vingadores Por Mark Waid - Volume 5', DATE '2024-05-01', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_vhk8lp5hip6p1f45q0lajl730i/-S897-f.webp')
), serie_waid AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE serie.id_externo = 'vingadores-por-mark-waid-panini-volume-1'
      AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    fonte_externa, id_externo, serie_id, data_criacao, data_atualizacao
)
SELECT
    capa.numero,
    'Vingadores Por Mark Waid #' || capa.numero,
    capa.subtitulo,
    capa.subtitulo,
    capa.data_publicacao,
    capa.url_capa,
    'PANINI',
    'vingadores-por-mark-waid-panini-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_waid serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    nome_volume = EXCLUDED.nome_volume,
    data_publicacao = EXCLUDED.data_publicacao,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;
