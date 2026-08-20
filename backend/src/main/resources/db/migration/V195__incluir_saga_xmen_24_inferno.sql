-- Inclui A Saga dos X-Men #24 no início de Inferno, depois do bloco da Excalibur.

WITH itens_bloco AS (
    SELECT item.id
    FROM itens_ordem_leitura item
    JOIN ordens_leitura ordem ON ordem.id = item.ordem_leitura_id
    WHERE ordem.slug = 'ordem-de-leitura-mutante'
      AND (
          (lower(trim(item.titulo_referencia)) = lower('Excalibur')
              AND item.detalhe_referencia IN ('V1 #1', 'V1 #2', 'V1 #3', 'V1 #4'))
          OR (lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
              AND item.detalhe_referencia = 'V1 #24')
      )
)
UPDATE itens_ordem_leitura item
SET posicao = item.posicao + 10000
FROM itens_bloco bloco
WHERE item.id = bloco.id;

WITH ordem AS (
    SELECT id FROM ordens_leitura WHERE slug = 'ordem-de-leitura-mutante'
), marco AS (
    SELECT item.posicao + 1 AS inicio
    FROM itens_ordem_leitura item
    JOIN ordem ON ordem.id = item.ordem_leitura_id
    WHERE lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
      AND item.detalhe_referencia = 'V1 #23'
), ordenacao AS (
    SELECT item.id,
        CASE
            WHEN lower(trim(item.titulo_referencia)) = lower('Excalibur') AND item.detalhe_referencia = 'V1 #1' THEN 1
            WHEN lower(trim(item.titulo_referencia)) = lower('Excalibur') AND item.detalhe_referencia = 'V1 #2' THEN 2
            WHEN lower(trim(item.titulo_referencia)) = lower('Excalibur') AND item.detalhe_referencia = 'V1 #3' THEN 3
            WHEN lower(trim(item.titulo_referencia)) = lower('Excalibur') AND item.detalhe_referencia = 'V1 #4' THEN 4
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men') AND item.detalhe_referencia = 'V1 #24' THEN 5
        END AS nova_ordem
    FROM itens_ordem_leitura item
    JOIN ordem ON ordem.id = item.ordem_leitura_id
    WHERE item.posicao >= 10000
)
UPDATE itens_ordem_leitura item
SET posicao = marco.inicio + ordenacao.nova_ordem - 1,
    secao = CASE
        WHEN ordenacao.nova_ordem <= 4
            THEN 'A Queda dos Mutantes, Wolverine em Madripoor, O Retorno da Ninhada e formação da Excalibur'
        ELSE 'Inferno'
    END
FROM ordenacao, marco
WHERE item.id = ordenacao.id
  AND ordenacao.nova_ordem IS NOT NULL;
