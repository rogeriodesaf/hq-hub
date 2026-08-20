-- Encerra a etapa do Massacre de Mutantes no volume 21 e organiza a etapa
-- seguinte com Queda dos Mutantes, Wolverine, Ninhada e Excalibur.

WITH descricoes(detalhe, texto) AS (VALUES
    ('V1 #16', E'MASSACRE DE MUTANTES\nOs Morlocks, mutantes que vivem nos subterrâneos de Nova York, são caçados pelos Carrascos, e os X-Men e o X-Factor combatem a ameaça.'),
    ('V1 #17', E'CONCLUSÃO DO MASSACRE DE MUTANTES\nA conclusão da saga Massacre de Mutantes.'),
    ('V1 #18', E'CAÇADA À TEMPESTADE\nTempestade está sendo caçada pelos antigos heróis da Segunda Guerra Mundial Muralha, Supersabre e o Comando Escarlate. Em combate aberto, ela não tem nenhuma chance contra eles, o que significa que precisará ser mais esperta.'),
    ('V1 #19', E'QUARTETO FANTÁSTICO CONTRA X-MEN\nOs X-Men precisam da ajuda do Quarteto Fantástico para salvar Kitty, mas os quatro heróis se recusam.'),
    ('V1 #20', E'X-MEN CONTRA VINGADORES\nOs Vingadores querem levar um Magneto reformado a julgamento, mas os X-Men querem protegê-lo.'),
    ('V1 #21', E'FORÇA FEDERAL E WOLVERINE CONTRA HULK\nOs X-Men enfrentam a Força Federal, enquanto Wolverine volta a confrontar o Hulk.')
)
UPDATE itens_ordem_leitura item
SET observacao = left(descricao.texto || E'\n\n' || coalesce(item.observacao, ''), 1000),
    secao = 'Massacre de Mutantes e formação do X-Factor'
FROM descricoes descricao, ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
  AND item.detalhe_referencia = descricao.detalhe;

-- Libera temporariamente as posições dos 14 itens que formarão a nova etapa.
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
            WHEN lower(trim(item.titulo_referencia)) = lower('Coleção Histórica Marvel: Wolverine') AND item.detalhe_referencia = 'V1 #3' THEN 5
            WHEN lower(trim(item.titulo_referencia)) = lower('Coleção Histórica Marvel: Wolverine') AND item.detalhe_referencia = 'V1 #4' THEN 6
            WHEN lower(trim(item.titulo_referencia)) = lower('Wolverine & Destrutor: Fusão') THEN 7
            WHEN lower(trim(item.titulo_referencia)) = lower('Coleção Histórica Marvel: Wolverine') AND item.detalhe_referencia = 'V1 #5' THEN 8
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men') AND item.detalhe_referencia = 'V1 #23' THEN 9
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men') AND item.detalhe_referencia = 'V1 #24' THEN 10
            WHEN lower(trim(item.titulo_referencia)) = lower('Excalibur') AND item.detalhe_referencia = 'V1 #1' THEN 11
            WHEN lower(trim(item.titulo_referencia)) = lower('Excalibur') AND item.detalhe_referencia = 'V1 #2' THEN 12
            WHEN lower(trim(item.titulo_referencia)) = lower('Excalibur') AND item.detalhe_referencia = 'V1 #3' THEN 13
            WHEN lower(trim(item.titulo_referencia)) = lower('Excalibur') AND item.detalhe_referencia = 'V1 #4' THEN 14
        END AS nova_ordem
    FROM itens_ordem_leitura item JOIN ordem ON ordem.id = item.ordem_leitura_id
    WHERE item.posicao >= 10000
      AND (
          lower(trim(item.titulo_referencia)) IN (
              lower('A Saga dos X-Men'), lower('Wolverine: A Maldição do Milênio'),
              lower('Coleção Histórica Marvel: Wolverine'), lower('Wolverine & Destrutor: Fusão'),
              lower('Excalibur')
          )
      )
)
UPDATE itens_ordem_leitura item
SET posicao = marco.inicio + ordenacao.nova_ordem - 1,
    secao = 'A Queda dos Mutantes, Wolverine em Madripoor, O Retorno da Ninhada e formação da Excalibur'
FROM ordenacao, marco
WHERE item.id = ordenacao.id
  AND ordenacao.nova_ordem IS NOT NULL;
