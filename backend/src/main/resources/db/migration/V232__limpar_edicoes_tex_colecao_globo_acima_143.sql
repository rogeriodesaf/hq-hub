-- Remove edicoes acima de 143 que foram vinculadas anteriormente, por engano,
-- a Tex Colecao da Globo. Preserva a serie e o intervalo correto 2 a 143.
CREATE TEMP TABLE hqhub_series_tex_colecao_globo ON COMMIT DROP AS
SELECT s.id
FROM series s
JOIN editoras e ON e.id = s.editora_id
WHERE hqhub_normalizar_titulo_serie(s.titulo) = hqhub_normalizar_titulo_serie('Tex Colecao')
  AND hqhub_normalizar_titulo_serie(e.nome) IN (
      hqhub_normalizar_titulo_serie('Globo'),
      hqhub_normalizar_titulo_serie('Editora Globo')
  )
  AND COALESCE(s.volume, 1) = 1;

CREATE TEMP TABLE hqhub_edicoes_tex_colecao_globo_excedentes ON COMMIT DROP AS
SELECT ed.id
FROM edicoes ed
JOIN hqhub_series_tex_colecao_globo serie ON serie.id = ed.serie_id
WHERE hqhub_normalizar_identidade(ed.numero) ~ '^[0-9]+$'
  AND hqhub_normalizar_identidade(ed.numero)::integer > 143;

DELETE FROM contribuicoes_catalogo
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_tex_colecao_globo_excedentes)
   OR edicao_destino_id IN (SELECT id FROM hqhub_edicoes_tex_colecao_globo_excedentes);

DELETE FROM publicacoes_historias
WHERE edicao_original_id IN (SELECT id FROM hqhub_edicoes_tex_colecao_globo_excedentes)
   OR edicao_publicada_id IN (SELECT id FROM hqhub_edicoes_tex_colecao_globo_excedentes);

DELETE FROM publicacoes_relacionadas
WHERE edicao_origem_id IN (SELECT id FROM hqhub_edicoes_tex_colecao_globo_excedentes)
   OR edicao_destino_id IN (SELECT id FROM hqhub_edicoes_tex_colecao_globo_excedentes);

DELETE FROM conteudos_edicoes
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_tex_colecao_globo_excedentes);

DELETE FROM creditos_edicoes
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_tex_colecao_globo_excedentes);

DELETE FROM itens_colecao
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_tex_colecao_globo_excedentes);

DELETE FROM compras_planejadas
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_tex_colecao_globo_excedentes);

DELETE FROM links_edicoes
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_tex_colecao_globo_excedentes);

DELETE FROM capas_edicao
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_tex_colecao_globo_excedentes);

DELETE FROM edicoes
WHERE id IN (SELECT id FROM hqhub_edicoes_tex_colecao_globo_excedentes);
