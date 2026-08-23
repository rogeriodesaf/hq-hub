-- Cadastra os onze volumes de Demolidor Por Mark Waid (Marvel Saga),
-- publicados pela Panini entre 2024 e 2025.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini Comics', 'Editora brasileira de quadrinhos.', 'Brasil', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Demolidor Por Mark Waid (Marvel Saga)',
    'Coleção completa em onze volumes da fase de Mark Waid à frente de Demolidor, publicada na linha Marvel Saga.',
    1,
    'PANINI',
    'demolidor-por-mark-waid-marvel-saga',
    'https://panini.com.br/demolidor-por-mark-waid-vol-01',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini Comics')
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

WITH capas(numero, ano_publicacao, url_capa) AS (VALUES
    ('1', 2024, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_gpk9ddahnh2nfcgea2p65sj97p/-S897-FWEBP'),
    ('2', 2024, 'https://rihappy.vtexassets.com/arquivos/ids/9066444/17582078270416.jpg?v=638942754369200000'),
    ('3', 2024, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_db21pkpqql61h010dmbp9hc12i/-S897-f.webp'),
    ('4', 2024, 'https://img.assinaja.com/assets/tZ/099/img/540782_900x900.png'),
    ('5', 2024, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_efcshq64hp3ln2ap8n4ev19k6m/-S897-f.webp'),
    ('6', 2024, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_o2qu8kpo712bp2t5mdclfcvo25/-S897-FWEBP'),
    ('7', 2024, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_b245rei1h10lv0h6ck86osi85e/-S897-f.webp'),
    ('8', 2024, 'https://img.assinaja.com/assets/tZ/099/img/596847_900x900.png'),
    ('9', 2024, 'https://img.assinaja.com/assets/tZ/099/img/596827_520x520.png'),
    ('10', 2025, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_e6m85ttf1930v8g00gpumm7s2i/-S897-FWEBP'),
    ('11', 2025, 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_rglhjo1mol53h537vd0apdmp51/-S897-f.webp')
), serie_demolidor AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE serie.id_externo = 'demolidor-por-mark-waid-marvel-saga'
      AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini Comics')
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    fonte_externa, id_externo, serie_id, data_criacao, data_atualizacao
)
SELECT
    capa.numero,
    'Demolidor Por Mark Waid Vol. ' || lpad(capa.numero, 2, '0'),
    'Volume ' || capa.numero || ' de Demolidor Por Mark Waid, da linha Marvel Saga.',
    'Volume ' || capa.numero,
    make_date(capa.ano_publicacao, 1, 1),
    capa.url_capa,
    'PANINI',
    'demolidor-por-mark-waid-marvel-saga-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_demolidor serie
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
