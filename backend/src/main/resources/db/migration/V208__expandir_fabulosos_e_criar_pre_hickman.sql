-- Incorpora a antiga etapa de Velho Logan ao bloco Fabulosos/Novíssimos e
-- cria, logo em seguida, a fase pré-Jonathan Hickman.

UPDATE itens_ordem_leitura item
SET observacao = left(
    E'O RETORNO DE CHARLES XAVIER\nCharles Xavier retorna nesta história.\n\n' || coalesce(item.observacao, ''),
    1000
)
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND lower(trim(item.titulo_referencia)) = lower('Surpreendentes X-Men: Um Homem Chamado X');

-- Afasta todas as posições para permitir a renumeração sem colisões.
UPDATE itens_ordem_leitura item
SET posicao = item.posicao + 100000
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante';

WITH ordem AS (
    SELECT id FROM ordens_leitura WHERE slug = 'ordem-de-leitura-mutante'
), marco AS (
    SELECT max(item.posicao - 100000) AS posicao_original
    FROM itens_ordem_leitura item JOIN ordem ON ordem.id = item.ordem_leitura_id
    WHERE item.secao = 'FABULOSOS X-MEN E NOVÍSSIMOS X-MEN'
), incorporados AS (
    SELECT item.id,
           row_number() OVER (ORDER BY item.posicao, item.id) AS ordem_bloco
    FROM itens_ordem_leitura item JOIN ordem ON ordem.id = item.ordem_leitura_id
    WHERE item.secao = 'Velho Logan, Guerra Civil II e Universo Marvel'
      AND lower(trim(item.titulo_referencia)) <> lower('Surpreendentes X-Men: Um Homem Chamado X')
), total_incorporados AS (
    SELECT count(*)::integer AS quantidade FROM incorporados
), pre_hickman AS (
    SELECT item.id,
           CASE
               WHEN lower(trim(item.titulo_referencia)) = lower('Surpreendentes X-Men: Um Homem Chamado X') THEN 1
               ELSE 1 + row_number() OVER (
                   PARTITION BY CASE WHEN item.secao = 'Retorno de Wolverine e Era do X-Man' THEN 1 ELSE 0 END
                   ORDER BY item.posicao, item.id
               )
           END AS ordem_bloco
    FROM itens_ordem_leitura item JOIN ordem ON ordem.id = item.ordem_leitura_id
    WHERE item.secao = 'Retorno de Wolverine e Era do X-Man'
       OR lower(trim(item.titulo_referencia)) = lower('Surpreendentes X-Men: Um Homem Chamado X')
), classificados AS (
    SELECT item.id,
           incorporado.ordem_bloco AS ordem_incorporado,
           pre.ordem_bloco AS ordem_pre,
           total.quantidade AS total_incorporado
    FROM itens_ordem_leitura item
    JOIN ordem ON ordem.id = item.ordem_leitura_id
    CROSS JOIN total_incorporados total
    LEFT JOIN incorporados incorporado ON incorporado.id = item.id
    LEFT JOIN pre_hickman pre ON pre.id = item.id
), ranqueados AS (
    SELECT item.id,
           row_number() OVER (
               ORDER BY CASE
                   WHEN classificado.ordem_incorporado IS NOT NULL
                       THEN marco.posicao_original + classificado.ordem_incorporado / 1000.0
                   WHEN classificado.ordem_pre IS NOT NULL
                       THEN marco.posicao_original + (classificado.total_incorporado + classificado.ordem_pre) / 1000.0
                   ELSE item.posicao - 100000
               END,
               item.id
           ) AS nova_posicao,
           classificado.ordem_incorporado,
           classificado.ordem_pre
    FROM itens_ordem_leitura item
    JOIN ordem ON ordem.id = item.ordem_leitura_id
    JOIN classificados classificado ON classificado.id = item.id
    CROSS JOIN marco
)
UPDATE itens_ordem_leitura item
SET posicao = ranqueado.nova_posicao,
    secao = CASE
        WHEN ranqueado.ordem_incorporado IS NOT NULL THEN 'FABULOSOS X-MEN E NOVÍSSIMOS X-MEN'
        WHEN ranqueado.ordem_pre IS NOT NULL THEN 'Fase pré-Jonathan Hickman'
        ELSE item.secao
    END
FROM ranqueados ranqueado
WHERE item.id = ranqueado.id;
