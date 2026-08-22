-- Garante as duas edições e aplica capas próprias à segunda edição de Marvel Deluxe: Thor.
-- Fonte das imagens: catálogo público da Rika.

WITH capas(numero, subtitulo, url_capa) AS (VALUES
    ('1', 'O Renascer dos Deuses', 'https://rika.vteximg.com.br/arquivos/ids/278890/marvel-deluxe-thor-renascer-dos-deuses.jpg?v=635877229500270000'),
    ('2', 'Em Nome do Pai', 'https://rika.vteximg.com.br/arquivos/ids/278490/marvel-deluxe-thor-em-nome-do-pai.jpg?v=635876953062100000')
), serie_thor AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Marvel Deluxe: Thor (2ª Edição)')
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
    capa.numero,
    'Marvel Deluxe: Thor (2ª Edição) #' || capa.numero,
    capa.subtitulo,
    capa.subtitulo,
    DATE '2015-01-01',
    capa.url_capa,
    'RIKA',
    'marvel-deluxe-thor-segunda-edicao-panini-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_thor serie
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
