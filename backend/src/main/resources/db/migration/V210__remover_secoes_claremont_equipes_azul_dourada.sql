-- Elimina duas seções residuais, realocando suas quatro edições nas etapas
-- cronológicas correspondentes sem remover conteúdo do guia.

-- Afasta todas as posições para permitir a renumeração sem colisões.
UPDATE itens_ordem_leitura item
SET posicao = item.posicao + 100000
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante';

WITH ordem AS (
    SELECT id FROM ordens_leitura WHERE slug = 'ordem-de-leitura-mutante'
), marcos AS (
    SELECT
        max(item.posicao - 100000) FILTER (
            WHERE lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
              AND item.detalhe_referencia = 'V1 #32'
        ) AS saga_32,
        max(item.posicao - 100000) FILTER (
            WHERE lower(trim(item.titulo_referencia)) = lower('A Saga do Wolverine')
              AND item.detalhe_referencia = 'V1 #1'
        ) AS wolverine_1,
        max(item.posicao - 100000) FILTER (
            WHERE lower(trim(item.titulo_referencia)) = lower('X-Men: A Era do Apocalipse')
              AND item.detalhe_referencia = 'V1 #1'
        ) AS era_apocalipse_1,
        max(item.posicao - 100000) FILTER (
            WHERE lower(trim(item.titulo_referencia)) = lower('A Saga do Wolverine')
              AND item.detalhe_referencia = 'V1 #9'
        ) AS wolverine_9
    FROM itens_ordem_leitura item JOIN ordem ON ordem.id = item.ordem_leitura_id
), realocados AS (
    SELECT item.id,
        CASE
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
                 AND item.detalhe_referencia = 'V1 #33' THEN 1
            WHEN lower(trim(item.titulo_referencia)) = lower('X-Factor Por Peter David') THEN 2
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
                 AND item.detalhe_referencia = 'V1 #36' THEN 3
            WHEN lower(trim(item.titulo_referencia)) = lower('Coleção Oficial de Graphic Novels Marvel — X-Men')
                 OR (lower(trim(item.titulo_referencia)) = lower('Coleção Oficial de Graphic Novels Marvel')
                     AND item.detalhe_referencia LIKE 'V1 #12%') THEN 4
        END AS destino
    FROM itens_ordem_leitura item JOIN ordem ON ordem.id = item.ordem_leitura_id
    WHERE item.secao IN (
        'O fim da era Claremont e novos caminhos',
        'Equipes Azul e Dourada e a chegada de Bishop'
    )
), ranqueados AS (
    SELECT item.id,
           row_number() OVER (
               ORDER BY CASE realocado.destino
                   WHEN 1 THEN marco.saga_32 + 0.1
                   WHEN 2 THEN marco.wolverine_1 - 0.1
                   WHEN 3 THEN marco.era_apocalipse_1 - 0.1
                   WHEN 4 THEN marco.wolverine_9 - 0.1
                   ELSE item.posicao - 100000
               END,
               item.id
           ) AS nova_posicao,
           realocado.destino
    FROM itens_ordem_leitura item
    JOIN ordem ON ordem.id = item.ordem_leitura_id
    LEFT JOIN realocados realocado ON realocado.id = item.id
    CROSS JOIN marcos marco
)
UPDATE itens_ordem_leitura item
SET posicao = ranqueado.nova_posicao,
    secao = CASE ranqueado.destino
        WHEN 1 THEN 'Novos Mutantes: a chegada de Cable e Saga da Ilha Muir'
        WHEN 2 THEN 'Nova formação do X-Factor e Wolverine por Larry Hama e Marc Silvestri'
        WHEN 3 THEN 'A Saga do Legião e a Era do Apocalipse'
        WHEN 4 THEN 'Grandes conflitos mutantes dos anos 1990'
        ELSE item.secao
    END
FROM ranqueados ranqueado
WHERE item.id = ranqueado.id;
