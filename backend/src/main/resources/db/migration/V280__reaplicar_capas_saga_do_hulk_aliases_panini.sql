-- Reaplica as capas na colecao ja existente, aceitando os nomes usados no
-- catalogo (A Saga do Hulk / Saga do Hulk, A e Panini / Panini Comics).

WITH capas(numero, data_publicacao, url_capa, url_origem) AS (VALUES
    ('1', DATE '2025-01-01', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_los0e3vck95u3dmc2ar1v55o7f/-S897-f.webp', 'https://panini.com.br/a-saga-do-hulk-01'),
    ('2', DATE '2025-03-01', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_n3jiog3ge575daib9an881m63s/-S897-f.webp', 'https://panini.com.br/a-saga-do-hulk-02'),
    ('3', DATE '2025-05-01', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_heotkpao516fh9a6n21pptiv5v/-S897-f.webp', 'https://panini.com.br/a-saga-do-hulk-03'),
    ('4', DATE '2025-07-01', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_93pgld12l52al5sntaodip6o0e/-S897-f.webp', 'https://panini.com.br/a-saga-do-hulk-04'),
    ('5', DATE '2025-09-01', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_rscdg8u6cd27b3esrjd6po1o6t/-S897-f.webp', 'https://panini.com.br/a-saga-do-hulk-05'),
    ('6', DATE '2025-11-01', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_73lqtsnsb17hj72t2fsoi7j61s/-S897-f.webp', 'https://panini.com.br/a-saga-do-hulk-06')
), series_hulk AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('A Saga do Hulk')
      AND hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    fonte_externa, id_externo, url_origem, serie_id, data_criacao, data_atualizacao
)
SELECT
    capa.numero,
    'A Saga do Hulk ' || lpad(capa.numero, 2, '0'),
    'Volume ' || capa.numero || ' de A Saga do Hulk, publicado pela Panini.',
    'Volume ' || capa.numero,
    capa.data_publicacao,
    capa.url_capa,
    'PANINI',
    'a-saga-do-hulk-panini-2025-' || capa.numero,
    capa.url_origem,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN series_hulk serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    nome_volume = EXCLUDED.nome_volume,
    data_publicacao = EXCLUDED.data_publicacao,
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;
