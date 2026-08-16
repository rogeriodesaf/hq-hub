-- Adiciona a capa oficial ao encadernado Guerras Secretas II (Marvel Vintage),
-- publicado pela Panini em 2026.

INSERT INTO series (
    titulo, descricao, ano_inicio, ano_fim, volume, fonte_externa, id_externo,
    url_origem, editora_id, data_criacao, data_atualizacao
)
SELECT
    'Guerras Secretas II',
    'Encadernado Marvel Vintage que reúne Secret Wars II 1 a 9.',
    2026,
    2026,
    1,
    'PANINI',
    'AGSII001',
    'https://panini.com.br/guerras-secretas-ii',
    editora.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM editoras editora
WHERE lower(trim(editora.nome)) = 'panini'
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO UPDATE SET
    descricao = EXCLUDED.descricao,
    ano_inicio = EXCLUDED.ano_inicio,
    ano_fim = EXCLUDED.ano_fim,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    data_atualizacao = CURRENT_TIMESTAMP;

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Guerras Secretas II')
      AND coalesce(serie.volume, 0) = 1
    ORDER BY serie.id
    LIMIT 1
)
UPDATE edicoes edicao
SET url_capa = 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_uqgv6h6nbl6f74vgn4f9ke7960/-S897-f.webp',
    fonte_externa = 'PANINI',
    id_externo = 'AGSII001',
    url_origem = 'https://panini.com.br/guerras-secretas-ii',
    data_atualizacao = CURRENT_TIMESTAMP
FROM serie_alvo serie
WHERE edicao.serie_id = serie.id;

WITH serie_alvo AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE lower(trim(editora.nome)) = 'panini'
      AND hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Guerras Secretas II')
      AND coalesce(serie.volume, 0) = 1
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, url_capa, fonte_externa, id_externo, url_origem, serie_id,
    data_criacao, data_atualizacao
)
SELECT
    'UNICA',
    'Guerras Secretas II',
    'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_uqgv6h6nbl6f74vgn4f9ke7960/-S897-f.webp',
    'PANINI',
    'AGSII001',
    'https://panini.com.br/guerras-secretas-ii',
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM serie_alvo serie
WHERE NOT EXISTS (
    SELECT 1
    FROM edicoes edicao
    WHERE edicao.serie_id = serie.id
);
