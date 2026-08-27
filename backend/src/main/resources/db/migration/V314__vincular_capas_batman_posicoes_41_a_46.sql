-- Vincula as capas solicitadas às posições 41 a 46 do guia cronológico do Batman.

WITH alvos AS (
    SELECT
        item.posicao,
        edicao.id AS edicao_id,
        edicao.url_capa,
        CASE item.posicao
            WHEN 41 THEN 'Vinculada a DC Comics - Coleção de Graphic Novels #96, da Eaglemoss.'
            WHEN 42 THEN 'Vinculada a DC Comics - Coleção de Graphic Novels #23, da Eaglemoss.'
            WHEN 43 THEN 'Vinculada a Batman - A Piada Mortal, Panini, V1.'
            WHEN 44 THEN 'Vinculada a DC Comics - Coleção de Graphic Novels: Sagas Definitivas #24, da Eaglemoss.'
            WHEN 45 THEN 'Vinculada a Batman: O Messias.'
            WHEN 46 THEN 'Vinculada a Batman: As Dez Noites da Besta.'
        END AS observacao
    FROM itens_ordem_leitura item
    JOIN ordens_leitura ordem ON ordem.id = item.ordem_leitura_id
    JOIN LATERAL (
        SELECT edicao.*
        FROM edicoes edicao
        JOIN series serie ON serie.id = edicao.serie_id
        JOIN editoras editora ON editora.id = serie.editora_id
        WHERE (
            item.posicao = 41
            AND hqhub_normalizar_titulo_serie(serie.titulo) LIKE '%dc comics%graphic novels%'
            AND hqhub_normalizar_titulo_serie(serie.titulo) NOT LIKE '%sagas definitivas%'
            AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%eaglemoss%'
            AND coalesce(edicao.numero, edicao.nome_volume, edicao.id_externo) ~ '(^|[^0-9])0*96([^0-9]|$)'
        ) OR (
            item.posicao = 42
            AND hqhub_normalizar_titulo_serie(serie.titulo) LIKE '%dc comics%graphic novels%'
            AND hqhub_normalizar_titulo_serie(serie.titulo) NOT LIKE '%sagas definitivas%'
            AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%eaglemoss%'
            AND coalesce(edicao.numero, edicao.nome_volume, edicao.id_externo) ~ '(^|[^0-9])0*23([^0-9]|$)'
        ) OR (
            item.posicao = 43
            AND hqhub_normalizar_titulo_serie(serie.titulo) LIKE '%piada mortal%'
            AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%panini%'
            AND coalesce(edicao.numero, edicao.nome_volume, '') ~ '(^|[^0-9])0*1([^0-9]|$)'
        ) OR (
            item.posicao = 44
            AND hqhub_normalizar_titulo_serie(serie.titulo) LIKE '%dc comics%graphic novels%sagas definitivas%'
            AND hqhub_normalizar_titulo_serie(editora.nome) LIKE '%eaglemoss%'
            AND coalesce(edicao.numero, edicao.nome_volume, edicao.id_externo) ~ '(^|[^0-9])0*24([^0-9]|$)'
        ) OR (
            item.posicao = 45
            AND hqhub_normalizar_titulo_serie(serie.titulo) LIKE '%batman%messias%'
        ) OR (
            item.posicao = 46
            AND hqhub_normalizar_titulo_serie(serie.titulo) LIKE '%dez noites% besta%'
        )
        ORDER BY edicao.id
        LIMIT 1
    ) edicao ON TRUE
    WHERE ordem.slug = 'batman-ordem-cronologica'
      AND item.posicao BETWEEN 41 AND 46
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
