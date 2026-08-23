-- Remove exclusivamente Nova Marvel Deluxe: Infinito, conforme solicitado.
-- Outras séries e revistas chamadas Infinito não são afetadas.

CREATE TEMP TABLE hqhub_series_nmd_infinito ON COMMIT DROP AS
SELECT serie.id
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
WHERE hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('Nova Marvel Deluxe: Infinito')
  AND hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND coalesce(serie.volume, 1) = 1;

CREATE TEMP TABLE hqhub_edicoes_nmd_infinito ON COMMIT DROP AS
SELECT edicao.id
FROM edicoes edicao
JOIN hqhub_series_nmd_infinito serie ON serie.id = edicao.serie_id;

DELETE FROM contribuicoes_catalogo
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_nmd_infinito)
   OR edicao_destino_id IN (SELECT id FROM hqhub_edicoes_nmd_infinito);

DELETE FROM publicacoes_historias
WHERE edicao_original_id IN (SELECT id FROM hqhub_edicoes_nmd_infinito)
   OR edicao_publicada_id IN (SELECT id FROM hqhub_edicoes_nmd_infinito);

DELETE FROM publicacoes_relacionadas
WHERE edicao_origem_id IN (SELECT id FROM hqhub_edicoes_nmd_infinito)
   OR edicao_destino_id IN (SELECT id FROM hqhub_edicoes_nmd_infinito);

DELETE FROM conteudos_edicoes
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_nmd_infinito);

DELETE FROM creditos_edicoes
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_nmd_infinito);

DELETE FROM itens_colecao
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_nmd_infinito);

DELETE FROM compras_planejadas
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_nmd_infinito);

DELETE FROM links_edicoes
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_nmd_infinito);

DELETE FROM capas_edicao
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_nmd_infinito);

DELETE FROM edicoes
WHERE id IN (SELECT id FROM hqhub_edicoes_nmd_infinito);

DELETE FROM colecoes_series
WHERE serie_id IN (SELECT id FROM hqhub_series_nmd_infinito);

DELETE FROM relacionamentos_series
WHERE serie_origem_id IN (SELECT id FROM hqhub_series_nmd_infinito)
   OR serie_destino_id IN (SELECT id FROM hqhub_series_nmd_infinito);

DELETE FROM series
WHERE id IN (SELECT id FROM hqhub_series_nmd_infinito);
