-- Remove exclusivamente Batman 4a Serie da Panini (volume 4),
-- incluindo suas edicoes e referencias dependentes.
CREATE TEMP TABLE hqhub_batman_quarta_serie_panini_remover ON COMMIT DROP AS
SELECT serie.id
FROM series serie
JOIN editoras editora ON editora.id = serie.editora_id
WHERE serie.volume = 4
  AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
  AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
      hqhub_normalizar_titulo_serie('Batman'),
      hqhub_normalizar_titulo_serie('Batman 4ª Série')
  );

CREATE TEMP TABLE hqhub_edicoes_batman_quarta_panini_remover ON COMMIT DROP AS
SELECT edicao.id
FROM edicoes edicao
WHERE edicao.serie_id IN (SELECT id FROM hqhub_batman_quarta_serie_panini_remover);

CREATE TEMP TABLE hqhub_itens_batman_quarta_panini_remover ON COMMIT DROP AS
SELECT item.id
FROM itens_colecao item
WHERE item.edicao_id IN (SELECT id FROM hqhub_edicoes_batman_quarta_panini_remover);

CREATE TEMP TABLE hqhub_anuncios_batman_quarta_panini_remover ON COMMIT DROP AS
SELECT anuncio.id
FROM anuncios anuncio
WHERE anuncio.item_colecao_id IN (SELECT id FROM hqhub_itens_batman_quarta_panini_remover);

DELETE FROM denuncias_anuncios
WHERE anuncio_id IN (SELECT id FROM hqhub_anuncios_batman_quarta_panini_remover);

DELETE FROM fotos_anuncios
WHERE anuncio_id IN (SELECT id FROM hqhub_anuncios_batman_quarta_panini_remover);

DELETE FROM anuncios
WHERE id IN (SELECT id FROM hqhub_anuncios_batman_quarta_panini_remover);

DELETE FROM contribuicoes_catalogo
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_batman_quarta_panini_remover)
   OR edicao_destino_id IN (SELECT id FROM hqhub_edicoes_batman_quarta_panini_remover);

DELETE FROM publicacoes_historias
WHERE edicao_original_id IN (SELECT id FROM hqhub_edicoes_batman_quarta_panini_remover)
   OR edicao_publicada_id IN (SELECT id FROM hqhub_edicoes_batman_quarta_panini_remover);

DELETE FROM publicacoes_relacionadas
WHERE edicao_origem_id IN (SELECT id FROM hqhub_edicoes_batman_quarta_panini_remover)
   OR edicao_destino_id IN (SELECT id FROM hqhub_edicoes_batman_quarta_panini_remover);

DELETE FROM conteudos_edicoes
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_batman_quarta_panini_remover);

DELETE FROM creditos_edicoes
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_batman_quarta_panini_remover);

DELETE FROM itens_colecao
WHERE id IN (SELECT id FROM hqhub_itens_batman_quarta_panini_remover);

DELETE FROM compras_planejadas
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_batman_quarta_panini_remover);

DELETE FROM links_edicoes
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_batman_quarta_panini_remover);

DELETE FROM capas_edicao
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_batman_quarta_panini_remover);

-- As referencias em itens_ordem_leitura e edicoes_atividades_estante usam
-- ON DELETE SET NULL e sao preservadas como historico.
DELETE FROM edicoes
WHERE id IN (SELECT id FROM hqhub_edicoes_batman_quarta_panini_remover);

DELETE FROM colecoes_series
WHERE serie_id IN (SELECT id FROM hqhub_batman_quarta_serie_panini_remover);

DELETE FROM relacionamentos_series
WHERE serie_origem_id IN (SELECT id FROM hqhub_batman_quarta_serie_panini_remover)
   OR serie_destino_id IN (SELECT id FROM hqhub_batman_quarta_serie_panini_remover);

-- postagens_feed.serie_catalogo_id usa ON DELETE SET NULL.
DELETE FROM series
WHERE id IN (SELECT id FROM hqhub_batman_quarta_serie_panini_remover);
