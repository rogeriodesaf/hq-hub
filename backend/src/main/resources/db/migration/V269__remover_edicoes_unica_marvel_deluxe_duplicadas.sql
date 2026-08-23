-- Remove as edicoes #UNICA duplicadas, preservando as edicoes numeradas corretas.
CREATE TEMP TABLE hqhub_edicoes_unica_marvel_deluxe_remover ON COMMIT DROP AS
SELECT edicao.id
FROM edicoes edicao
JOIN series serie ON serie.id = edicao.serie_id
JOIN editoras editora ON editora.id = serie.editora_id
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('UNICA')
  AND hqhub_normalizar_titulo_serie(serie.titulo) IN (
      hqhub_normalizar_titulo_serie('Marvel Deluxe: A Era de Ultron'),
      hqhub_normalizar_titulo_serie('Marvel Deluxe: A Essencia do Medo'),
      hqhub_normalizar_titulo_serie('Marvel Deluxe: Capitao Marvel'),
      hqhub_normalizar_titulo_serie('Marvel Deluxe: Guerra Civil'),
      hqhub_normalizar_titulo_serie('Marvel Deluxe: Invasao Secreta'),
      hqhub_normalizar_titulo_serie('Marvel Deluxe: Vingadores A Queda'),
      hqhub_normalizar_titulo_serie('Marvel Deluxe: Vingadores Vs. X-Men')
  );

CREATE TEMP TABLE hqhub_series_unica_marvel_deluxe_revisar ON COMMIT DROP AS
SELECT DISTINCT edicao.serie_id AS id
FROM edicoes edicao
WHERE edicao.id IN (SELECT id FROM hqhub_edicoes_unica_marvel_deluxe_remover);

DELETE FROM contribuicoes_catalogo
WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_unica_marvel_deluxe_remover)
   OR edicao_destino_id IN (SELECT id FROM hqhub_edicoes_unica_marvel_deluxe_remover);

DELETE FROM publicacoes_historias
WHERE edicao_original_id IN (SELECT id FROM hqhub_edicoes_unica_marvel_deluxe_remover)
   OR edicao_publicada_id IN (SELECT id FROM hqhub_edicoes_unica_marvel_deluxe_remover);

DELETE FROM publicacoes_relacionadas
WHERE edicao_origem_id IN (SELECT id FROM hqhub_edicoes_unica_marvel_deluxe_remover)
   OR edicao_destino_id IN (SELECT id FROM hqhub_edicoes_unica_marvel_deluxe_remover);

DELETE FROM conteudos_edicoes WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_unica_marvel_deluxe_remover);
DELETE FROM creditos_edicoes WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_unica_marvel_deluxe_remover);
DELETE FROM itens_colecao WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_unica_marvel_deluxe_remover);
DELETE FROM compras_planejadas WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_unica_marvel_deluxe_remover);
DELETE FROM links_edicoes WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_unica_marvel_deluxe_remover);
DELETE FROM capas_edicao WHERE edicao_id IN (SELECT id FROM hqhub_edicoes_unica_marvel_deluxe_remover);
DELETE FROM edicoes WHERE id IN (SELECT id FROM hqhub_edicoes_unica_marvel_deluxe_remover);

DELETE FROM colecoes_series
WHERE serie_id IN (
    SELECT alvo.id
    FROM hqhub_series_unica_marvel_deluxe_revisar alvo
    WHERE NOT EXISTS (SELECT 1 FROM edicoes edicao WHERE edicao.serie_id = alvo.id)
);

DELETE FROM relacionamentos_series
WHERE serie_origem_id IN (
        SELECT alvo.id
        FROM hqhub_series_unica_marvel_deluxe_revisar alvo
        WHERE NOT EXISTS (SELECT 1 FROM edicoes edicao WHERE edicao.serie_id = alvo.id)
    )
   OR serie_destino_id IN (
        SELECT alvo.id
        FROM hqhub_series_unica_marvel_deluxe_revisar alvo
        WHERE NOT EXISTS (SELECT 1 FROM edicoes edicao WHERE edicao.serie_id = alvo.id)
    );

DELETE FROM series serie
WHERE serie.id IN (SELECT id FROM hqhub_series_unica_marvel_deluxe_revisar)
  AND NOT EXISTS (SELECT 1 FROM edicoes edicao WHERE edicao.serie_id = serie.id);
