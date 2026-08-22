-- Remove exclusivamente a serie duplicada "Tex", da editora nomeada exatamente
-- como "RGE", volume 1. A colecao canonica "RGE / Rio Grafica" e preservada.
CREATE TEMP TABLE hqhub_series_tex_rge_duplicada ON COMMIT DROP AS
SELECT s.id
FROM series s
JOIN editoras e ON e.id = s.editora_id
WHERE hqhub_normalizar_titulo_serie(s.titulo) = hqhub_normalizar_titulo_serie('Tex')
  AND hqhub_normalizar_titulo_serie(e.nome) = hqhub_normalizar_titulo_serie('RGE')
  AND COALESCE(s.volume, 1) = 1;

CREATE TEMP TABLE hqhub_edicoes_tex_rge_duplicada ON COMMIT DROP AS
SELECT ed.id
FROM edicoes ed
JOIN hqhub_series_tex_rge_duplicada alvo ON alvo.id = ed.serie_id;

DELETE FROM contribuicoes_catalogo
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_tex_rge_duplicada)
   OR edicao_destino_id IN (SELECT id FROM hqhub_edicoes_tex_rge_duplicada);

DELETE FROM publicacoes_historias
WHERE edicao_original_id IN (SELECT id FROM hqhub_edicoes_tex_rge_duplicada)
   OR edicao_publicada_id IN (SELECT id FROM hqhub_edicoes_tex_rge_duplicada);

DELETE FROM publicacoes_relacionadas
WHERE edicao_origem_id IN (SELECT id FROM hqhub_edicoes_tex_rge_duplicada)
   OR edicao_destino_id IN (SELECT id FROM hqhub_edicoes_tex_rge_duplicada);

DELETE FROM conteudos_edicoes
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_tex_rge_duplicada);

DELETE FROM creditos_edicoes
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_tex_rge_duplicada);

DELETE FROM itens_colecao
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_tex_rge_duplicada);

DELETE FROM compras_planejadas
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_tex_rge_duplicada);

DELETE FROM links_edicoes
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_tex_rge_duplicada);

DELETE FROM capas_edicao
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_tex_rge_duplicada);

DELETE FROM edicoes
WHERE id IN (SELECT id FROM hqhub_edicoes_tex_rge_duplicada);

DELETE FROM colecoes_series
WHERE serie_id IN (SELECT id FROM hqhub_series_tex_rge_duplicada);

DELETE FROM relacionamentos_series
WHERE serie_origem_id IN (SELECT id FROM hqhub_series_tex_rge_duplicada)
   OR serie_destino_id IN (SELECT id FROM hqhub_series_tex_rge_duplicada);

DELETE FROM series
WHERE id IN (SELECT id FROM hqhub_series_tex_rge_duplicada);
