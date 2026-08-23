-- Consolida o registro legado de Guardioes da Galaxia e remove definitivamente
-- qualquer variacao importada de "apitao America: Sam Wilson".
CREATE TEMP TABLE hqhub_serie_guardioes_legada ON COMMIT DROP AS
SELECT serie.id
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND hqhub_normalizar_titulo_serie(serie.titulo) LIKE '%guardioes da galaxia%'
  AND hqhub_normalizar_titulo_serie(serie.titulo) LIKE '%soldado do amanha%'
ORDER BY serie.id
LIMIT 1;

CREATE TEMP TABLE hqhub_series_remover_correcao_nmd ON COMMIT DROP AS
SELECT serie.id
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND (
      (
          hqhub_normalizar_titulo_serie(serie.titulo) LIKE '%apitao america%'
          AND hqhub_normalizar_titulo_serie(serie.titulo) LIKE '%sam wilson%'
      )
      OR (
          EXISTS (SELECT 1 FROM hqhub_serie_guardioes_legada)
          AND hqhub_normalizar_titulo_serie(serie.titulo) =
              hqhub_normalizar_titulo_serie('Nova Marvel Deluxe: Guardioes da Galaxia')
          AND serie.id NOT IN (SELECT id FROM hqhub_serie_guardioes_legada)
      )
  );

CREATE TEMP TABLE hqhub_edicoes_remover_correcao_nmd ON COMMIT DROP AS
SELECT edicao.id
FROM edicoes edicao
WHERE edicao.serie_id IN (SELECT id FROM hqhub_series_remover_correcao_nmd)
   OR edicao.serie_id IN (SELECT id FROM hqhub_serie_guardioes_legada);

DELETE FROM contribuicoes_catalogo
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_remover_correcao_nmd)
   OR edicao_destino_id IN (SELECT id FROM hqhub_edicoes_remover_correcao_nmd);

DELETE FROM publicacoes_historias
WHERE edicao_original_id IN (SELECT id FROM hqhub_edicoes_remover_correcao_nmd)
   OR edicao_publicada_id IN (SELECT id FROM hqhub_edicoes_remover_correcao_nmd);

DELETE FROM publicacoes_relacionadas
WHERE edicao_origem_id IN (SELECT id FROM hqhub_edicoes_remover_correcao_nmd)
   OR edicao_destino_id IN (SELECT id FROM hqhub_edicoes_remover_correcao_nmd);

DELETE FROM conteudos_edicoes WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_remover_correcao_nmd);
DELETE FROM creditos_edicoes WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_remover_correcao_nmd);
DELETE FROM itens_colecao WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_remover_correcao_nmd);
DELETE FROM compras_planejadas WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_remover_correcao_nmd);
DELETE FROM links_edicoes WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_remover_correcao_nmd);
DELETE FROM capas_edicao WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_remover_correcao_nmd);
DELETE FROM edicoes WHERE id IN (SELECT id FROM hqhub_edicoes_remover_correcao_nmd);

DELETE FROM colecoes_series WHERE serie_id IN (SELECT id FROM hqhub_series_remover_correcao_nmd);
DELETE FROM relacionamentos_series
WHERE serie_origem_id IN (SELECT id FROM hqhub_series_remover_correcao_nmd)
   OR serie_destino_id IN (SELECT id FROM hqhub_series_remover_correcao_nmd);
DELETE FROM series WHERE id IN (SELECT id FROM hqhub_series_remover_correcao_nmd);

UPDATE series serie
SET titulo = 'Nova Marvel Deluxe: Guardiões da Galáxia',
    descricao = 'Guardiões da Galáxia na linha Nova Marvel Deluxe, publicada pela Panini em dois volumes.',
    fonte_externa = 'PANINI',
    id_externo = 'nova-marvel-deluxe-guardioes-da-galaxia-panini-v1',
    url_origem = 'https://panini.com.br/guardioes-da-galaxia-vol-1-imperador-quill',
    tipo_serie = 'BRASILEIRA',
    data_atualizacao = CURRENT_TIMESTAMP
WHERE serie.id IN (SELECT id FROM hqhub_serie_guardioes_legada);

INSERT INTO series (
    titulo, descricao, volume, fonte_externa, id_externo,
    url_origem, editora_id, tipo_serie, data_criacao, data_atualizacao
)
SELECT
    'Nova Marvel Deluxe: Guardiões da Galáxia',
    'Guardiões da Galáxia na linha Nova Marvel Deluxe, publicada pela Panini em dois volumes.',
    1, 'PANINI', 'nova-marvel-deluxe-guardioes-da-galaxia-panini-v1',
    'https://panini.com.br/guardioes-da-galaxia-vol-1-imperador-quill',
    editora.id, 'BRASILEIRA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
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
    ('1', 'Imperador Quill', DATE '2023-03-01',
     'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_vdkm1d4u3d4dp49itpq48be77i/-S897-f.webp'),
    ('2', 'Guerra Civil II', DATE '2023-05-01',
     'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_smqpl447r554jaott19raekc77/-S897-f.webp')
), serie_guardioes AS (
    SELECT serie.id
    FROM series serie
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE serie.id_externo = 'nova-marvel-deluxe-guardioes-da-galaxia-panini-v1'
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
    'Nova Marvel Deluxe: Guardiões da Galáxia #' || capa.numero,
    capa.subtitulo,
    capa.subtitulo,
    capa.data_publicacao,
    capa.url_capa,
    'PANINI',
    'nova-marvel-deluxe-guardioes-da-galaxia-panini-' || capa.numero,
    serie.id,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM capas capa
CROSS JOIN serie_guardioes serie
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
