-- Fecha Inferno nos volumes 25 e 26 e organiza a fase australiana com
-- as leituras complementares de Wolverine antes de A Saga dos X-Men #31.

WITH descricoes(titulo, detalhe, texto) AS (VALUES
    ('A Saga dos X-Men', 'V1 #25',
     E'INFERNO — INÍCIO\nMadelyne Pryor, a clone de Jean Grey, torna-se uma feiticeira e transforma Nova York em um inferno. Os X-Men começam a passar por transformações demoníacas e entram em confronto direto com o X-Factor.'),
    ('A Saga dos X-Men', 'V1 #26',
     E'INFERNO — CONCLUSÃO\nA origem de Madelyne Pryor é enfim revelada! Por que ela deseja se vingar de Ciclope? Quem orquestrou cada evento de sua vida?'),
    ('A Saga dos X-Men', 'V1 #27',
     E'FASE AUSTRALIANA E ESTREIA DE JUBILEU\nApós os eventos da Saga Inferno, os X-Men são atacados de forma voraz pelos Sentinelas. Ao mesmo tempo, um pedido de socorro de Polaris chama os mutantes para uma nova aventura na Terra Selvagem. É aqui que ocorre a estreia da garota Jubileu!'),
    ('Coleção Histórica Marvel: Wolverine', 'V1 #3',
     E'WOLVERINE CONTRA DENTES-DE-SABRE E VAMPIROS\nNo presente e em suas lembranças, Logan enfrenta aquele que é provavelmente o seu maior inimigo: Dentes-de-Sabre! Este volume também traz o arco de Wolverine contra os vampiros.'),
    ('Coleção Histórica Marvel: Wolverine', 'V1 #4',
     E'WOLVERINE EM MADRIPOOR\nWolverine utiliza seus sentidos aguçados para encontrar carregamentos de cocaína na agourenta ilha de Madripoor e descobre que alguém está usando uma droga experimental para criar estranhos superseres. Que vilão poderia estar por trás disso?'),
    ('Coleção Histórica Marvel: Wolverine', 'V1 #5',
     E'WOLVERINE NA ANTÁRTIDA\nLogan se vê numa floresta luxuriante habitada por dinossauros, em plena Antártida.'),
    ('A Saga dos X-Men', 'V1 #28',
     E'ZALADANE, OS CARNICEIROS E JUBILEU\nA conclusão do arco dos mutantes remanescentes contra a temível Zaladane. Ocorre aqui também o emblemático confronto dos Carniceiros de Donald Pierce contra Wolverine, no qual Jubileu o salva.'),
    ('A Saga dos X-Men', 'V1 #29',
     E'LEGIÃO, PSYLOCKE E O TENTÁCULO\nSina entra num perigoso jogo mental com Legião, e as consequências podem ser mortíferas! Psylocke sofre uma lavagem cerebral e é transformada em assassina para o Mandarim, enquanto a conspiração dos ninjas do Tentáculo leva Wolverine a ser capturado.'),
    ('A Saga dos X-Men', 'V1 #30',
     E'ESTREIA DE GAMBIT E A BUSCA POR JEAN GREY\nEm um restaurante em Madripoor, Wolverine, Psylocke e Jubileu são atacados por mercenários. Banshee e Forge juntam forças para resgatar Jean Grey. Primeira aparição de Gambit.'),
    ('A Saga dos X-Men', 'V1 #31',
     E'TEMPESTADE E GAMBIT\nUma Tempestade pré-adolescente e Gambit tornam-se parceiros, assaltando as ruas de Nova Orleans, mas primeiro precisam enfrentar a Babá e o Fazedor de Órfãos, que os perseguem. Vampira batalha contra a força vital de Carol Danvers depois de perder algumas de suas habilidades como Ms. Marvel.')
)
UPDATE itens_ordem_leitura item
SET observacao = left(descricao.texto || E'\n\n' || coalesce(item.observacao, ''), 1000)
FROM descricoes descricao, ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND lower(trim(item.titulo_referencia)) = lower(descricao.titulo)
  AND item.detalhe_referencia = descricao.detalhe;

-- Libera todo o intervalo até A Saga do Wolverine #3, inclusive, para que
-- os itens possam ser reorganizados sem colisões de posição.
WITH itens_bloco AS (
    SELECT item.id
    FROM itens_ordem_leitura item
    JOIN ordens_leitura ordem ON ordem.id = item.ordem_leitura_id
    WHERE ordem.slug = 'ordem-de-leitura-mutante'
      AND (
          (lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
              AND item.detalhe_referencia IN ('V1 #25', 'V1 #26', 'V1 #27', 'V1 #28', 'V1 #29', 'V1 #30', 'V1 #31'))
          OR (lower(trim(item.titulo_referencia)) = lower('Coleção Histórica Marvel: Wolverine')
              AND item.detalhe_referencia IN ('V1 #3', 'V1 #4', 'V1 #5'))
          OR lower(trim(item.titulo_referencia)) = lower('Wolverine & Destrutor: Fusão')
          OR (lower(trim(item.titulo_referencia)) = lower('A Saga do Wolverine')
              AND item.detalhe_referencia IN ('V1 #1', 'V1 #2', 'V1 #3'))
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
    WHERE lower(trim(item.titulo_referencia)) = lower('Excalibur')
      AND item.detalhe_referencia = 'V1 #4'
), ordenacao AS (
    SELECT item.id,
        CASE
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men') AND item.detalhe_referencia = 'V1 #25' THEN 1
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men') AND item.detalhe_referencia = 'V1 #26' THEN 2
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men') AND item.detalhe_referencia = 'V1 #27' THEN 3
            WHEN lower(trim(item.titulo_referencia)) = lower('Coleção Histórica Marvel: Wolverine') AND item.detalhe_referencia = 'V1 #3' THEN 4
            WHEN lower(trim(item.titulo_referencia)) = lower('Coleção Histórica Marvel: Wolverine') AND item.detalhe_referencia = 'V1 #4' THEN 5
            WHEN lower(trim(item.titulo_referencia)) = lower('Wolverine & Destrutor: Fusão') THEN 6
            WHEN lower(trim(item.titulo_referencia)) = lower('Coleção Histórica Marvel: Wolverine') AND item.detalhe_referencia = 'V1 #5' THEN 7
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men') AND item.detalhe_referencia = 'V1 #28' THEN 8
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men') AND item.detalhe_referencia = 'V1 #29' THEN 9
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men') AND item.detalhe_referencia = 'V1 #30' THEN 10
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men') AND item.detalhe_referencia = 'V1 #31' THEN 11
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga do Wolverine') AND item.detalhe_referencia = 'V1 #1' THEN 12
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga do Wolverine') AND item.detalhe_referencia = 'V1 #2' THEN 13
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga do Wolverine') AND item.detalhe_referencia = 'V1 #3' THEN 14
        END AS nova_ordem
    FROM itens_ordem_leitura item JOIN ordem ON ordem.id = item.ordem_leitura_id
    WHERE item.posicao >= 10000
)
UPDATE itens_ordem_leitura item
SET posicao = marco.inicio + ordenacao.nova_ordem - 1,
    secao = CASE
        WHEN ordenacao.nova_ordem <= 2 THEN 'Inferno'
        WHEN ordenacao.nova_ordem <= 11 THEN 'A fase australiana e Wolverine e histórias complementares'
        ELSE 'A Saga do Wolverine'
    END
FROM ordenacao, marco
WHERE item.id = ordenacao.id
  AND ordenacao.nova_ordem IS NOT NULL;
