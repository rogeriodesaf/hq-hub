-- Remove exclusivamente a série "Almanaque Tex", da Mythos Editora, volume 1,
-- junto das edições e dos vínculos que dependem desse cadastro.
CREATE TEMP TABLE hqhub_series_almanaque_tex ON COMMIT DROP AS
SELECT s.id
FROM series s
JOIN editoras e ON e.id = s.editora_id
WHERE hqhub_normalizar_titulo_serie(s.titulo) = hqhub_normalizar_titulo_serie('Almanaque Tex')
  AND hqhub_normalizar_titulo_serie(e.nome) = hqhub_normalizar_titulo_serie('Mythos Editora')
  AND COALESCE(s.volume, 1) = 1;

CREATE TEMP TABLE hqhub_edicoes_almanaque_tex ON COMMIT DROP AS
SELECT ed.id
FROM edicoes ed
JOIN hqhub_series_almanaque_tex alvo ON alvo.id = ed.serie_id;

DELETE FROM contribuicoes_catalogo
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_almanaque_tex)
   OR edicao_destino_id IN (SELECT id FROM hqhub_edicoes_almanaque_tex);

DELETE FROM publicacoes_historias
WHERE edicao_original_id IN (SELECT id FROM hqhub_edicoes_almanaque_tex)
   OR edicao_publicada_id IN (SELECT id FROM hqhub_edicoes_almanaque_tex);

DELETE FROM publicacoes_relacionadas
WHERE edicao_origem_id IN (SELECT id FROM hqhub_edicoes_almanaque_tex)
   OR edicao_destino_id IN (SELECT id FROM hqhub_edicoes_almanaque_tex);

DELETE FROM conteudos_edicoes
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_almanaque_tex);

DELETE FROM creditos_edicoes
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_almanaque_tex);

DELETE FROM itens_colecao
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_almanaque_tex);

DELETE FROM compras_planejadas
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_almanaque_tex);

DELETE FROM links_edicoes
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_almanaque_tex);

DELETE FROM capas_edicao
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_almanaque_tex);

DELETE FROM edicoes
WHERE id IN (SELECT id FROM hqhub_edicoes_almanaque_tex);

DELETE FROM colecoes_series
WHERE serie_id IN (SELECT id FROM hqhub_series_almanaque_tex);

DELETE FROM relacionamentos_series
WHERE serie_origem_id IN (SELECT id FROM hqhub_series_almanaque_tex)
   OR serie_destino_id IN (SELECT id FROM hqhub_series_almanaque_tex);

DELETE FROM series
WHERE id IN (SELECT id FROM hqhub_series_almanaque_tex);
