-- Corrige os vínculos das posições 57 a 59 aceitando os títulos completos
-- das séries/edições (por exemplo, "Batman: A Queda do Morcego").

WITH referencias(posicao, termo, observacao) AS (
    VALUES
        (57, '%queda%morcego%', 'Vinculada a A Queda do Morcego, edição já cadastrada no catálogo.'),
        (58, '%cruzada%morcego%', 'Vinculada a A Cruzada do Morcego, edição já cadastrada no catálogo.'),
        (59, '%crepusculo%morcego%', 'Vinculada a O Crepúsculo do Morcego, edição já cadastrada no catálogo.')
), alvos AS (
    SELECT referencia.posicao, edicao.id AS edicao_id, edicao.url_capa, referencia.observacao
    FROM referencias referencia
    JOIN LATERAL (
        SELECT edicao.*
        FROM edicoes edicao
        JOIN series serie ON serie.id = edicao.serie_id
        WHERE nullif(trim(edicao.url_capa), '') IS NOT NULL
          AND (
              hqhub_normalizar_titulo_serie(coalesce(serie.titulo, '')) LIKE referencia.termo
              OR hqhub_normalizar_titulo_serie(coalesce(edicao.titulo, '')) LIKE referencia.termo
              OR hqhub_normalizar_titulo_serie(coalesce(edicao.nome_volume, '')) LIKE referencia.termo
              OR hqhub_normalizar_titulo_serie(coalesce(edicao.descricao, '')) LIKE referencia.termo
          )
        ORDER BY
            CASE
                WHEN hqhub_normalizar_titulo_serie(coalesce(serie.titulo, '')) LIKE referencia.termo THEN 0
                WHEN hqhub_normalizar_titulo_serie(coalesce(edicao.titulo, '')) LIKE referencia.termo THEN 1
                WHEN hqhub_normalizar_titulo_serie(coalesce(edicao.nome_volume, '')) LIKE referencia.termo THEN 2
                ELSE 3
            END,
            edicao.id
        LIMIT 1
    ) edicao ON TRUE
)
UPDATE itens_ordem_leitura item
SET edicao_id = alvo.edicao_id,
    url_capa_referencia = alvo.url_capa,
    status_identificacao = 'CONFIRMADO',
    observacao = alvo.observacao
FROM alvos alvo
JOIN ordens_leitura ordem ON ordem.slug = 'batman-ordem-cronologica'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = alvo.posicao;
