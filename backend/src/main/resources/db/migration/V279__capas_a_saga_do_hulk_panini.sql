-- Cadastra A Saga do Hulk, publicada pela Panini em 2025, e aplica as capas
-- oficiais dos seis volumes. O Guia dos Quadrinhos nao foi usado como fonte.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini', 'Editora de quadrinhos e colecoes.', 'Italia', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'A Saga do Hulk',
    'Colecao da Panini que republica no Brasil a fase do Hulk Vermelho iniciada em Hulk (2008).',
    1,
    'PANINI',
    'a-saga-do-hulk-panini-2025',
    'https://panini.com.br/a-saga-do-hulk-01',
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND NOT EXISTS (
      SELECT 1
      FROM series existente
      JOIN editoras editora_existente ON editora_existente.id = existente.editora_id
      WHERE hqhub_normalizar_titulo_serie(existente.titulo) =
            hqhub_normalizar_titulo_serie('A Saga do Hulk')
        AND coalesce(existente.volume, 1) = 1
        AND hqhub_normalizar_titulo_serie(editora_existente.nome) LIKE 'panini%'
  )
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

WITH capas(numero, data_publicacao, url_capa, url_origem) AS (VALUES
    ('1', DATE '2025-01-01', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_los0e3vck95u3dmc2ar1v55o7f/-S897-f.webp', 'https://panini.com.br/a-saga-do-hulk-01'),
    ('2', DATE '2025-03-01', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_n3jiog3ge575daib9an881m63s/-S897-f.webp', 'https://panini.com.br/a-saga-do-hulk-02'),
    ('3', DATE '2025-05-01', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_heotkpao516fh9a6n21pptiv5v/-S897-f.webp', 'https://panini.com.br/a-saga-do-hulk-03'),
    ('4', DATE '2025-07-01', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_93pgld12l52al5sntaodip6o0e/-S897-f.webp', 'https://panini.com.br/a-saga-do-hulk-04'),
    ('5', DATE '2025-09-01', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_rscdg8u6cd27b3esrjd6po1o6t/-S897-f.webp', 'https://panini.com.br/a-saga-do-hulk-05'),
    ('6', DATE '2025-11-01', 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_73lqtsnsb17hj72t2fsoi7j61s/-S897-f.webp', 'https://panini.com.br/a-saga-do-hulk-06')
), serie_hulk AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie('A Saga do Hulk')
      AND coalesce(serie.volume, 1) = 1
      AND hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%'
    ORDER BY
        CASE WHEN serie.id_externo = 'a-saga-do-hulk-panini-2025' THEN 0 ELSE 1 END,
        (SELECT count(*) FROM edicoes edicao WHERE edicao.serie_id = serie.id) DESC,
        serie.id
    LIMIT 1
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
CROSS JOIN serie_hulk serie
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
