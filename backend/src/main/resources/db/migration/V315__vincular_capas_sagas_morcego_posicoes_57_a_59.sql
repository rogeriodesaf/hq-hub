-- Vincula as capas das sagas do Morcego às posições 57 a 59 do guia do Batman.

WITH referencias(posicao, termo, observacao) AS (
    VALUES
        (57, 'queda%morcego', 'Vinculada a A Queda do Morcego, edição já cadastrada no catálogo.'),
        (58, 'cruzada%morcego', 'Vinculada a A Cruzada do Morcego, edição já cadastrada no catálogo.'),
        (59, 'crepusculo%morcego', 'Vinculada a O Crepúsculo do Morcego, edição já cadastrada no catálogo.')
), alvos AS (
    SELECT referencia.posicao, edicao.id AS edicao_id, edicao.url_capa, referencia.observacao
    FROM referencias referencia
    JOIN LATERAL (
        SELECT edicao.*
        FROM edicoes edicao
        JOIN series serie ON serie.id = edicao.serie_id
        WHERE hqhub_normalizar_titulo_serie(serie.titulo) LIKE referencia.termo
        ORDER BY edicao.id
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
