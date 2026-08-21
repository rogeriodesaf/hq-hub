-- Organiza a Saga do Legião e a Era do Apocalipse, apresentando os volumes
-- regulares e o Omnibus como formas alternativas de leitura da megassaga.

WITH descricoes(titulo, detalhe, texto) AS (VALUES
    ('X-Men: A Era do Apocalipse', 'V1 #1',
     E'A ERA DO APOCALIPSE — VOLUME 1\nComo consequência da Saga do Legião, Magneto assume o sonho de Xavier e forma os X-Men. Apocalipse surge dez anos antes e muda completamente o futuro. Esta megassaga mutante dos anos 1990 também está reunida em X-Men: A Era do Apocalipse Omnibus.'),
    ('X-Men: A Era do Apocalipse', 'V1 #2',
     E'A ERA DO APOCALIPSE — VOLUME 2\nContinuação e conclusão da megassaga. Este material também está reunido em X-Men: A Era do Apocalipse Omnibus.'),
    ('X-Men: A Era do Apocalipse Omnibus', NULL,
     E'A SAGA DO LEGIÃO E A ERA DO APOCALIPSE\nLegião, filho do Professor Xavier, volta no tempo para assassinar Magneto. Xavier, porém, morre protegendo o amigo, criando o paradoxo que dá origem à Era do Apocalipse. Magneto assume o sonho de Xavier e forma os X-Men, enquanto Apocalipse surge dez anos antes e transforma completamente o futuro.\n\nEDIÇÃO ALTERNATIVA\nO Omnibus reúne a megassaga também publicada no guia em X-Men: A Era do Apocalipse #1 e #2.')
)
UPDATE itens_ordem_leitura item
SET observacao = left(descricao.texto || E'\n\n' || coalesce(item.observacao, ''), 1000)
FROM descricoes descricao, ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND lower(trim(item.titulo_referencia)) = lower(descricao.titulo)
  AND item.detalhe_referencia IS NOT DISTINCT FROM descricao.detalhe;

-- Afasta todas as posições para permitir a renumeração sem colisões.
UPDATE itens_ordem_leitura item
SET posicao = item.posicao + 100000
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante';

WITH ordem AS (
    SELECT id FROM ordens_leitura WHERE slug = 'ordem-de-leitura-mutante'
), marco AS (
    SELECT item.posicao - 100000 AS posicao_original
    FROM itens_ordem_leitura item JOIN ordem ON ordem.id = item.ordem_leitura_id
    WHERE lower(trim(item.titulo_referencia)) = lower('X-Men: Aliança Falange')
), prioridades AS (
    SELECT item.id,
        CASE
            WHEN lower(trim(item.titulo_referencia)) = lower('X-Men: A Era do Apocalipse')
                 AND item.detalhe_referencia = 'V1 #1' THEN 1
            WHEN lower(trim(item.titulo_referencia)) = lower('X-Men: A Era do Apocalipse')
                 AND item.detalhe_referencia = 'V1 #2' THEN 2
            WHEN lower(trim(item.titulo_referencia)) = lower('X-Men: A Era do Apocalipse Omnibus') THEN 3
        END AS ordem_etapa
    FROM itens_ordem_leitura item JOIN ordem ON ordem.id = item.ordem_leitura_id
), ranqueados AS (
    SELECT prioridade.id,
           row_number() OVER (
               ORDER BY CASE
                   WHEN prioridade.ordem_etapa IS NOT NULL
                       THEN marco.posicao_original + prioridade.ordem_etapa / 100.0
                   ELSE item.posicao - 100000
               END,
               item.id
           ) AS nova_posicao,
           prioridade.ordem_etapa
    FROM prioridades prioridade
    JOIN itens_ordem_leitura item ON item.id = prioridade.id
    CROSS JOIN marco
)
UPDATE itens_ordem_leitura item
SET posicao = ranqueado.nova_posicao,
    secao = CASE WHEN ranqueado.ordem_etapa IS NOT NULL
        THEN 'A Saga do Legião e a Era do Apocalipse'
        ELSE item.secao
    END
FROM ranqueados ranqueado
WHERE item.id = ranqueado.id;
