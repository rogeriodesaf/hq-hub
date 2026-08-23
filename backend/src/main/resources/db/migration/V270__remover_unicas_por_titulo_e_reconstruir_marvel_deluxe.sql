-- A importacao legada gravou alguns nomes no titulo da edicao, e nao no titulo
-- da serie. Remove esses #UNICA e elimina referencias orfas da pagina publica.
CREATE TEMP TABLE hqhub_unicas_marvel_deluxe_por_titulo ON COMMIT DROP AS
SELECT edicao.id
FROM edicoes edicao
JOIN series serie ON serie.id = edicao.serie_id
JOIN editoras editora ON editora.id = serie.editora_id
WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
  AND hqhub_normalizar_identidade(edicao.numero) = hqhub_normalizar_identidade('UNICA')
  AND (
      hqhub_normalizar_titulo_serie(edicao.titulo) IN (
          hqhub_normalizar_titulo_serie('Marvel Deluxe: A Era de Ultron'),
          hqhub_normalizar_titulo_serie('Marvel Deluxe: A Essencia do Medo'),
          hqhub_normalizar_titulo_serie('Marvel Deluxe: Capitao Marvel'),
          hqhub_normalizar_titulo_serie('Marvel Deluxe: Guerra Civil'),
          hqhub_normalizar_titulo_serie('Marvel Deluxe: Invasao Secreta'),
          hqhub_normalizar_titulo_serie('Marvel Deluxe: Vingadores A Queda'),
          hqhub_normalizar_titulo_serie('Marvel Deluxe: Vingadores Vs. X-Men')
      )
      OR hqhub_normalizar_titulo_serie(serie.titulo) IN (
          hqhub_normalizar_titulo_serie('Marvel Deluxe: A Era de Ultron'),
          hqhub_normalizar_titulo_serie('Marvel Deluxe: A Essencia do Medo'),
          hqhub_normalizar_titulo_serie('Marvel Deluxe: Capitao Marvel'),
          hqhub_normalizar_titulo_serie('Marvel Deluxe: Guerra Civil'),
          hqhub_normalizar_titulo_serie('Marvel Deluxe: Invasao Secreta'),
          hqhub_normalizar_titulo_serie('Marvel Deluxe: Vingadores A Queda'),
          hqhub_normalizar_titulo_serie('Marvel Deluxe: Vingadores Vs. X-Men')
      )
  );

CREATE TEMP TABLE hqhub_series_unicas_marvel_deluxe_por_titulo ON COMMIT DROP AS
SELECT DISTINCT edicao.serie_id AS id
FROM edicoes edicao
WHERE edicao.id IN (SELECT id FROM hqhub_unicas_marvel_deluxe_por_titulo);

DELETE FROM contribuicoes_catalogo
WHERE edicao_id IN (SELECT id FROM hqhub_unicas_marvel_deluxe_por_titulo)
   OR edicao_destino_id IN (SELECT id FROM hqhub_unicas_marvel_deluxe_por_titulo);
DELETE FROM publicacoes_historias
WHERE edicao_original_id IN (SELECT id FROM hqhub_unicas_marvel_deluxe_por_titulo)
   OR edicao_publicada_id IN (SELECT id FROM hqhub_unicas_marvel_deluxe_por_titulo);
DELETE FROM publicacoes_relacionadas
WHERE edicao_origem_id IN (SELECT id FROM hqhub_unicas_marvel_deluxe_por_titulo)
   OR edicao_destino_id IN (SELECT id FROM hqhub_unicas_marvel_deluxe_por_titulo);
DELETE FROM conteudos_edicoes WHERE edicao_id IN (SELECT id FROM hqhub_unicas_marvel_deluxe_por_titulo);
DELETE FROM creditos_edicoes WHERE edicao_id IN (SELECT id FROM hqhub_unicas_marvel_deluxe_por_titulo);
DELETE FROM itens_colecao WHERE edicao_id IN (SELECT id FROM hqhub_unicas_marvel_deluxe_por_titulo);
DELETE FROM compras_planejadas WHERE edicao_id IN (SELECT id FROM hqhub_unicas_marvel_deluxe_por_titulo);
DELETE FROM links_edicoes WHERE edicao_id IN (SELECT id FROM hqhub_unicas_marvel_deluxe_por_titulo);
DELETE FROM capas_edicao WHERE edicao_id IN (SELECT id FROM hqhub_unicas_marvel_deluxe_por_titulo);
DELETE FROM edicoes WHERE id IN (SELECT id FROM hqhub_unicas_marvel_deluxe_por_titulo);

DELETE FROM colecoes_series
WHERE serie_id IN (
    SELECT alvo.id FROM hqhub_series_unicas_marvel_deluxe_por_titulo alvo
    WHERE NOT EXISTS (SELECT 1 FROM edicoes edicao WHERE edicao.serie_id = alvo.id)
);
DELETE FROM relacionamentos_series
WHERE serie_origem_id IN (
        SELECT alvo.id FROM hqhub_series_unicas_marvel_deluxe_por_titulo alvo
        WHERE NOT EXISTS (SELECT 1 FROM edicoes edicao WHERE edicao.serie_id = alvo.id)
    )
   OR serie_destino_id IN (
        SELECT alvo.id FROM hqhub_series_unicas_marvel_deluxe_por_titulo alvo
        WHERE NOT EXISTS (SELECT 1 FROM edicoes edicao WHERE edicao.serie_id = alvo.id)
    );
DELETE FROM series serie
WHERE serie.id IN (SELECT id FROM hqhub_series_unicas_marvel_deluxe_por_titulo)
  AND NOT EXISTS (SELECT 1 FROM edicoes edicao WHERE edicao.serie_id = serie.id);

-- Reconstrucao integral evita que itens com edicao_id nulo continuem visiveis.
DELETE FROM itens_ordem_leitura
WHERE ordem_leitura_id = (
    SELECT id FROM ordens_leitura WHERE slug = 'colecao-marvel-deluxe-capa-preta'
);

WITH edicoes_marvel_deluxe AS (
    SELECT
        edicao.id AS edicao_id,
        serie.titulo AS secao,
        edicao.numero,
        edicao.titulo,
        edicao.nome_volume,
        edicao.url_capa,
        edicao.data_publicacao,
        row_number() OVER (
            ORDER BY hqhub_normalizar_titulo_serie(serie.titulo),
                CASE WHEN hqhub_normalizar_identidade(edicao.numero) ~ '^[0-9]+$'
                    THEN hqhub_normalizar_identidade(edicao.numero)::integer ELSE 2147483647 END,
                edicao.id
        )::integer AS posicao
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE hqhub_normalizar_titulo_serie(editora.nome) = hqhub_normalizar_titulo_serie('Panini')
      AND serie.id_externo LIKE 'marvel-deluxe-%-panini-v1'
      AND hqhub_normalizar_identidade(edicao.numero) <> hqhub_normalizar_identidade('UNICA')
)
INSERT INTO itens_ordem_leitura (
    ordem_leitura_id, posicao, secao, edicao_id, titulo_referencia,
    detalhe_referencia, url_capa_referencia, status_identificacao,
    observacao, ano_referencia
)
SELECT
    ordem.id, item.posicao, item.secao, item.edicao_id,
    coalesce(item.titulo, item.secao || ' #' || item.numero),
    coalesce(item.nome_volume, item.secao), item.url_capa, 'CONFIRMADO',
    'Edição da coleção Marvel Deluxe de capa preta publicada pela Panini.',
    CASE WHEN item.data_publicacao IS NOT NULL
        THEN extract(year FROM item.data_publicacao)::integer ELSE NULL END
FROM edicoes_marvel_deluxe item
JOIN ordens_leitura ordem ON ordem.slug = 'colecao-marvel-deluxe-capa-preta';
