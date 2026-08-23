-- Cadastra as capas de Guardiões da Galáxia e Capitão América: O Soldado do Amanhã
-- na linha Nova Marvel Deluxe. Imagens obtidas diretamente da Panini.

INSERT INTO editoras (nome, descricao, pais_origem, data_criacao, data_atualizacao)
VALUES ('Panini', 'Editora de quadrinhos e coleções.', 'Itália', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (nome) DO UPDATE SET data_atualizacao = CURRENT_TIMESTAMP;

WITH catalogo(titulo, descricao, id_externo, url_origem) AS (VALUES
    ('Nova Marvel Deluxe: Guardiões da Galáxia',
     'Guardiões da Galáxia na linha Nova Marvel Deluxe, publicada pela Panini em dois volumes.',
     'nova-marvel-deluxe-guardioes-da-galaxia-panini-v1',
     'https://panini.com.br/guardioes-da-galaxia-vol-1-imperador-quill'),
    ('Nova Marvel Deluxe: Capitão América: O Soldado do Amanhã',
     'Capitão América: O Soldado do Amanhã, volume único da linha Nova Marvel Deluxe.',
     'nova-marvel-deluxe-capitao-america-soldado-do-amanha-panini-v1',
     'https://panini.com.br/capitao-america-o-soldado-do-amanha')
)
INSERT INTO series (
    titulo, descricao, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    catalogo.titulo,
    catalogo.descricao,
    1,
    'PANINI',
    catalogo.id_externo,
    catalogo.url_origem,
    editora.id,
    'BRASILEIRA',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM catalogo
CROSS JOIN LATERAL (
    SELECT id
    FROM editoras
    WHERE hqhub_normalizar_titulo_serie(nome) = hqhub_normalizar_titulo_serie('Panini')
    ORDER BY id
    LIMIT 1
) editora
ON CONFLICT (editora_id, coalesce(volume, 0), hqhub_normalizar_titulo_serie(titulo))
DO UPDATE SET
    descricao = EXCLUDED.descricao,
    fonte_externa = EXCLUDED.fonte_externa,
    id_externo = EXCLUDED.id_externo,
    url_origem = EXCLUDED.url_origem,
    tipo_serie = 'BRASILEIRA',
    data_atualizacao = CURRENT_TIMESTAMP;

WITH capas(titulo_serie, numero, subtitulo, data_publicacao, url_capa) AS (VALUES
    ('Nova Marvel Deluxe: Guardiões da Galáxia', '1', 'Imperador Quill', DATE '2023-03-01',
     'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_vdkm1d4u3d4dp49itpq48be77i/-S897-f.webp'),
    ('Nova Marvel Deluxe: Guardiões da Galáxia', '2', 'Guerra Civil II', DATE '2023-05-01',
     'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_smqpl447r554jaott19raekc77/-S897-f.webp'),
    ('Nova Marvel Deluxe: Capitão América: O Soldado do Amanhã', '1', 'O Soldado do Amanhã', DATE '2022-02-01',
     'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_jmpm6jnhgp2j1eehi92j8fe63g/-S897-f.webp')
), series_destino AS (
    SELECT serie.id, serie.titulo
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE serie.id_externo IN (
        'nova-marvel-deluxe-guardioes-da-galaxia-panini-v1',
        'nova-marvel-deluxe-capitao-america-soldado-do-amanha-panini-v1'
    )
      AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
)
INSERT INTO edicoes (
    numero, titulo, descricao, nome_volume, data_publicacao, url_capa,
    fonte_externa, id_externo, serie_id, data_criacao, data_atualizacao
)
SELECT
    capa.numero,
    capa.titulo_serie || CASE WHEN capa.numero = '1' AND capa.titulo_serie LIKE '%Soldado do Amanhã' THEN '' ELSE ' #' || capa.numero END,
    capa.subtitulo,
    capa.subtitulo,
    capa.data_publicacao,
    capa.url_capa,
    'PANINI',
    CASE
        WHEN capa.titulo_serie LIKE '%Guardiões da Galáxia' THEN 'nova-marvel-deluxe-guardioes-da-galaxia-panini-' || capa.numero
        ELSE 'nova-marvel-deluxe-capitao-america-soldado-do-amanha-panini-1'
    END,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
JOIN series_destino serie
  ON hqhub_normalizar_titulo_serie(serie.titulo) = hqhub_normalizar_titulo_serie(capa.titulo_serie)
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
