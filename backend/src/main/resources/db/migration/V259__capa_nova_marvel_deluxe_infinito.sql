-- Garante o encadernado Infinito da linha Nova Marvel Deluxe com capa oficial.
-- Não altera as revistas mensais homônimas.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini', 'Editora de quadrinhos e coleções.', 'Itália', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Nova Marvel Deluxe: Infinito',
    'Encadernado Infinito, de Jonathan Hickman, publicado pela Panini na linha Nova Marvel Deluxe.',
    1,
    'PANINI',
    'nova-marvel-deluxe-infinito-panini-v1',
    'https://panini.com.br/infinito',
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

WITH serie_infinito AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Nova Marvel Deluxe: Infinito')
      AND coalesce(serie.volume, 1) = 1
      AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    fonte_externa, id_externo, serie_id, data_criacao, data_atualizacao
)
SELECT
    '1',
    'Nova Marvel Deluxe: Infinito',
    'Reúne Infinity 1-6, com roteiro de Jonathan Hickman.',
    'Infinito',
    DATE '2017-02-01',
    'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_ils3o1arlt26n915o6if8jcb47/-S897-f.webp',
    'PANINI',
    'nova-marvel-deluxe-infinito-panini-1',
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM serie_infinito serie
ON CONFLICT (serie_id, hqhub_normalizar_identidade(numero))
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    nome_volume = EXCLUDED.nome_volume,
    data_publicacao = coalesce(edicoes.data_publicacao, EXCLUDED.data_publicacao),
    url_capa = EXCLUDED.url_capa,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    data_atualizacao = CURRENT_TIMESTAMP;
