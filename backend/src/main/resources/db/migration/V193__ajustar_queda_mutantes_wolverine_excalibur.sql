-- Refina a etapa de Queda dos Mutantes e separa quatro leituras de Wolverine
-- para a subseção imediatamente seguinte.

WITH descricoes(titulo, detalhe, texto) AS (VALUES
    ('Coleção Histórica Marvel: Wolverine', 'V1 #1',
     E'WOLVERINE EM MADRIPOOR\nAqui começa a fase de Wolverine em Madripoor. É aqui que Wolverine ganha a alcunha de Caolho.'),
    ('A Saga dos X-Men', 'V1 #23',
     E'O RETORNO DA NINHADA\nQuando uma infestação da Ninhada chega ao Colorado, os X-Men precisam entrar em ação para impedir um massacre. Paralelamente, Madelyne Pryor tem uma visão que pode ser o fim definitivo de tudo entre ela e Scott.'),
    ('A Saga dos X-Men', 'V1 #24',
     E'SEGREDOS DE GENOSHA\nVampira e Logan perdem seus poderes. Será que sobreviverão o suficiente para que os X-Men alcancem Genosha?'),
    ('Excalibur', 'V1 #1',
     E'FORMAÇÃO DA EXCALIBUR\nApós a Queda dos Mutantes, Noturno e Kitty Pryde formam uma nova equipe: a Excalibur.'),
    ('Excalibur', 'V1 #2',
     E'FORMAÇÃO DA EXCALIBUR\nApós a Queda dos Mutantes, Noturno e Kitty Pryde formam uma nova equipe: a Excalibur.'),
    ('Excalibur', 'V1 #3',
     E'FORMAÇÃO DA EXCALIBUR\nApós a Queda dos Mutantes, Noturno e Kitty Pryde formam uma nova equipe: a Excalibur.'),
    ('Excalibur', 'V1 #4',
     E'FORMAÇÃO DA EXCALIBUR\nApós a Queda dos Mutantes, Noturno e Kitty Pryde formam uma nova equipe: a Excalibur.')
)
UPDATE itens_ordem_leitura item
SET observacao = left(descricao.texto || E'\n\n' || coalesce(item.observacao, ''), 1000)
FROM descricoes descricao, ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND lower(trim(item.titulo_referencia)) = lower(descricao.titulo)
  AND item.detalhe_referencia = descricao.detalhe;

-- Libera as posições do mesmo bloco de 14 itens organizado pela V192.
WITH itens_bloco AS (
    SELECT item.id
    FROM itens_ordem_leitura item
    JOIN ordens_leitura ordem ON ordem.id = item.ordem_leitura_id
    WHERE ordem.slug = 'ordem-de-leitura-mutante'
      AND (
          (lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
              AND item.detalhe_referencia IN ('V1 #22', 'V1 #23', 'V1 #24'))
          OR lower(trim(item.titulo_referencia)) = lower('Wolverine: A Maldição do Milênio')
          OR (lower(trim(item.titulo_referencia)) = lower('Coleção Histórica Marvel: Wolverine')
              AND item.detalhe_referencia IN ('V1 #1', 'V1 #2', 'V1 #3', 'V1 #4', 'V1 #5'))
          OR lower(trim(item.titulo_referencia)) = lower('Wolverine & Destrutor: Fusão')
          OR (lower(trim(item.titulo_referencia)) = lower('Excalibur')
              AND item.detalhe_referencia IN ('V1 #1', 'V1 #2', 'V1 #3', 'V1 #4'))
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
    FROM itens_ordem_leitura item JOIN ordem ON ordem.id = item.ordem_leitura_id
    WHERE lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
      AND item.detalhe_referencia = 'V1 #21'
), ordenacao AS (
    SELECT item.id,
        CASE
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men') AND item.detalhe_referencia = 'V1 #22' THEN 1
            WHEN lower(trim(item.titulo_referencia)) = lower('Wolverine: A Maldição do Milênio') THEN 2
            WHEN lower(trim(item.titulo_referencia)) = lower('Coleção Histórica Marvel: Wolverine') AND item.detalhe_referencia = 'V1 #1' THEN 3
            WHEN lower(trim(item.titulo_referencia)) = lower('Coleção Histórica Marvel: Wolverine') AND item.detalhe_referencia = 'V1 #2' THEN 4
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men') AND item.detalhe_referencia = 'V1 #23' THEN 5
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men') AND item.detalhe_referencia = 'V1 #24' THEN 6
            WHEN lower(trim(item.titulo_referencia)) = lower('Excalibur') AND item.detalhe_referencia = 'V1 #1' THEN 7
            WHEN lower(trim(item.titulo_referencia)) = lower('Excalibur') AND item.detalhe_referencia = 'V1 #2' THEN 8
            WHEN lower(trim(item.titulo_referencia)) = lower('Excalibur') AND item.detalhe_referencia = 'V1 #3' THEN 9
            WHEN lower(trim(item.titulo_referencia)) = lower('Excalibur') AND item.detalhe_referencia = 'V1 #4' THEN 10
            WHEN lower(trim(item.titulo_referencia)) = lower('Coleção Histórica Marvel: Wolverine') AND item.detalhe_referencia = 'V1 #3' THEN 11
            WHEN lower(trim(item.titulo_referencia)) = lower('Coleção Histórica Marvel: Wolverine') AND item.detalhe_referencia = 'V1 #4' THEN 12
            WHEN lower(trim(item.titulo_referencia)) = lower('Wolverine & Destrutor: Fusão') THEN 13
            WHEN lower(trim(item.titulo_referencia)) = lower('Coleção Histórica Marvel: Wolverine') AND item.detalhe_referencia = 'V1 #5' THEN 14
        END AS nova_ordem
    FROM itens_ordem_leitura item JOIN ordem ON ordem.id = item.ordem_leitura_id
    WHERE item.posicao >= 10000
), nova_etapa AS (
    SELECT
        'A Queda dos Mutantes, Wolverine em Madripoor, O Retorno da Ninhada e formação da Excalibur'::varchar AS atual,
        'Wolverine: histórias complementares'::varchar AS seguinte
)
UPDATE itens_ordem_leitura item
SET posicao = marco.inicio + ordenacao.nova_ordem - 1,
    secao = CASE WHEN ordenacao.nova_ordem <= 10 THEN etapa.atual ELSE etapa.seguinte END
FROM ordenacao, marco, nova_etapa etapa
WHERE item.id = ordenacao.id
  AND ordenacao.nova_ordem IS NOT NULL;
