-- Corrige a capa do volume único Homem de Ferro Superior, da Nova Marvel Deluxe.
-- Atualiza a edição existente (inclusive quando numerada como UNICA) e só cria uma se faltar.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini', 'Editora de quadrinhos e coleções.', 'Itália', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

INSERT INTO series (
    titulo, descricao, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Nova Marvel Deluxe: Homem de Ferro Superior',
    'Homem de Ferro Superior, volume único publicado pela Panini na linha Nova Marvel Deluxe.',
    1,
    'PANINI',
    'nova-marvel-deluxe-homem-de-ferro-superior-panini-v1',
    'https://panini.com.br/homem-de-ferro-superior',
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

UPDATE edicoes edicao
SET titulo = 'Nova Marvel Deluxe: Homem de Ferro Superior',
    descricao = 'Reúne Superior Iron Man 1-9.',
    nome_volume = 'Homem de Ferro Superior',
    data_publicacao = coalesce(edicao.data_publicacao, DATE '2022-03-01'),
    url_capa = 'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_5aliq79oad1ht36nd8g21oiu7u/-S897-f.webp',
    fonte_externa = 'PANINI',
    data_atualizacao = CURRENT_TIMESTAMP
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
WHERE edicao.serie_id = serie.id
  AND hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('Nova Marvel Deluxe: Homem de Ferro Superior')
  AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND coalesce(serie.volume, 1) = 1;

WITH serie_ferro AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
          hqhub_normalizar_titulo_serie('Nova Marvel Deluxe: Homem de Ferro Superior')
      AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
      AND coalesce(serie.volume, 1) = 1
    ORDER BY serie.id
    LIMIT 1
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    fonte_externa, id_externo, serie_id, data_criacao, data_atualizacao
)
SELECT
    'UNICA',
    'Nova Marvel Deluxe: Homem de Ferro Superior',
    'Reúne Superior Iron Man 1-9.',
    'Homem de Ferro Superior',
    DATE '2022-03-01',
    'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_5aliq79oad1ht36nd8g21oiu7u/-S897-f.webp',
    'PANINI',
    'nova-marvel-deluxe-homem-de-ferro-superior-panini-unica',
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM serie_ferro serie
WHERE NOT EXISTS (
    SELECT 1 FROM edicoes edicao WHERE edicao.serie_id = serie.id
);
