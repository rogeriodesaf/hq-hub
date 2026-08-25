-- Vincula Batgirl: Ano Um ao guia cronologico do Batman.
-- Prioriza a edicao brasileira mais recente da Panini e, em caso de empate,
-- a edicao mais completa e que ja possua capa.

WITH edicao_batgirl AS (
    SELECT edicao.id, edicao.url_capa, edicao.data_publicacao
    FROM edicoes edicao
    JOIN series serie ON serie.id = edicao.serie_id
    JOIN editoras editora ON editora.id = serie.editora_id
    WHERE (
        hqhub_normalizar_titulo_serie(edicao.titulo) =
            hqhub_normalizar_titulo_serie('Batgirl: Ano Um')
        OR hqhub_normalizar_titulo_serie(serie.titulo) =
            hqhub_normalizar_titulo_serie('Batgirl: Ano Um')
    )
    ORDER BY
        CASE WHEN hqhub_normalizar_titulo_serie(editora.nome) LIKE 'panini%' THEN 0 ELSE 1 END,
        edicao.data_publicacao DESC NULLS LAST,
        edicao.quantidade_paginas DESC NULLS LAST,
        CASE WHEN nullif(trim(edicao.url_capa), '') IS NOT NULL THEN 0 ELSE 1 END,
        edicao.id
    LIMIT 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = edicao.id,
    url_capa_referencia = coalesce(edicao.url_capa, item.url_capa_referencia),
    status_identificacao = 'CONFIRMADO',
    observacao = 'Vinculada a edicao brasileira mais recente de Batgirl: Ano Um.',
    ano_referencia = coalesce(EXTRACT(YEAR FROM edicao.data_publicacao)::integer, item.ano_referencia)
FROM edicao_batgirl edicao
JOIN ordens_leitura ordem ON ordem.slug = 'batman-ordem-cronologica'
WHERE item.ordem_leitura_id = ordem.id
  AND hqhub_normalizar_titulo_serie(item.titulo_referencia) =
      hqhub_normalizar_titulo_serie('Batgirl: Ano Um');
