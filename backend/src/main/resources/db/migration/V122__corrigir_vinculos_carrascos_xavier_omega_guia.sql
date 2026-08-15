-- Corrige de forma determinística os vínculos que não foram resolvidos pela
-- comparação textual da V121. As posições são as entradas canônicas da ordem
-- mutante e os identificadores são as referências oficiais da Panini.

WITH vinculos(posicao, id_externo, url_capa) AS (VALUES
    (
        505,
        'AXMCA001',
        'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_fdencqndc15r57fiqqdnlld126/-S265-FWEBP'
    ),
    (
        621,
        'AXOME001',
        'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_fe685752f11t91brcculec2214/-S265-FWEBP'
    )
), edicoes_alvo AS (
    SELECT
        vinculo.posicao,
        vinculo.url_capa,
        edicao.id AS edicao_id,
        row_number() OVER (
            PARTITION BY vinculo.posicao
            ORDER BY CASE WHEN edicao.fonte_externa = 'PANINI' THEN 0 ELSE 1 END, edicao.id
        ) AS prioridade
    FROM vinculos vinculo
    JOIN edicoes edicao ON edicao.id_externo = vinculo.id_externo
)
UPDATE itens_ordem_leitura item
SET edicao_id = alvo.edicao_id,
    url_capa_referencia = alvo.url_capa
FROM edicoes_alvo alvo
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = alvo.posicao
  AND alvo.prioridade = 1;

-- Mantém a capa visível mesmo se a edição do catálogo for temporariamente
-- desvinculada ou estiver indisponível durante uma revisão futura.
WITH capas(posicao, url_capa) AS (VALUES
    (
        505,
        'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_fdencqndc15r57fiqqdnlld126/-S265-FWEBP'
    ),
    (
        621,
        'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/image_fe685752f11t91brcculec2214/-S265-FWEBP'
    )
)
UPDATE itens_ordem_leitura item
SET url_capa_referencia = capa.url_capa
FROM capas capa
JOIN ordens_leitura ordem ON ordem.slug = 'ordem-de-leitura-mutante'
WHERE item.ordem_leitura_id = ordem.id
  AND item.posicao = capa.posicao;
