-- Remove exclusivamente o registro importado com "Capitao" sem a letra C.
-- A serie canonica "Nova Marvel Deluxe: Capitao America: Sam Wilson" e preservada.
CREATE TEMP TABLE hqhub_series_sam_wilson_titulo_incorreto ON COMMIT DROP AS
SELECT serie.id
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND hqhub_normalizar_titulo_serie(serie.titulo) =
      hqhub_normalizar_titulo_serie('Nova Marvel Deluxe: apitao America: Sam Wilson');

CREATE TEMP TABLE hqhub_edicoes_sam_wilson_titulo_incorreto ON COMMIT DROP AS
SELECT edicao.id
FROM edicoes edicao
JOIN hqhub_series_sam_wilson_titulo_incorreto serie ON serie.id = edicao.serie_id;

DELETE FROM contribuicoes_catalogo
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_sam_wilson_titulo_incorreto)
   OR edicao_destino_id IN (SELECT id FROM hqhub_edicoes_sam_wilson_titulo_incorreto);

DELETE FROM publicacoes_historias
WHERE edicao_original_id IN (SELECT id FROM hqhub_edicoes_sam_wilson_titulo_incorreto)
   OR edicao_publicada_id IN (SELECT id FROM hqhub_edicoes_sam_wilson_titulo_incorreto);

DELETE FROM publicacoes_relacionadas
WHERE edicao_origem_id IN (SELECT id FROM hqhub_edicoes_sam_wilson_titulo_incorreto)
   OR edicao_destino_id IN (SELECT id FROM hqhub_edicoes_sam_wilson_titulo_incorreto);

DELETE FROM conteudos_edicoes
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_sam_wilson_titulo_incorreto);

DELETE FROM creditos_edicoes
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_sam_wilson_titulo_incorreto);

DELETE FROM itens_colecao
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_sam_wilson_titulo_incorreto);

DELETE FROM compras_planejadas
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_sam_wilson_titulo_incorreto);

DELETE FROM links_edicoes
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_sam_wilson_titulo_incorreto);

DELETE FROM capas_edicao
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_sam_wilson_titulo_incorreto);

DELETE FROM edicoes
WHERE id IN (SELECT id FROM hqhub_edicoes_sam_wilson_titulo_incorreto);

DELETE FROM colecoes_series
WHERE serie_id IN (SELECT id FROM hqhub_series_sam_wilson_titulo_incorreto);

DELETE FROM relacionamentos_series
WHERE serie_origem_id IN (SELECT id FROM hqhub_series_sam_wilson_titulo_incorreto)
   OR serie_destino_id IN (SELECT id FROM hqhub_series_sam_wilson_titulo_incorreto);

DELETE FROM series
WHERE id IN (SELECT id FROM hqhub_series_sam_wilson_titulo_incorreto);
