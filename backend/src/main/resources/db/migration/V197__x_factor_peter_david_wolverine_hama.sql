-- Organiza a nova formação do X-Factor e o início da fase de Wolverine
-- por Larry Hama e Marc Silvestri imediatamente após a etapa da Ilha Muir.

WITH descricoes(detalhe, texto) AS (VALUES
    ('V1 #1',
     'LARRY HAMA E MARC SILVESTRI — Início da marcante fase de Wolverine com Larry Hama nos roteiros e Marc Silvestri nos desenhos.'),
    ('V1 #2',
     'GUERRA CIVIL ESPANHOLA — O incrível arco de Wolverine contra Lady Letal durante a Guerra Civil Espanhola!'),
    ('V1 #3',
     'CONFRONTO EM TIMES SQUARE — O famoso confronto contra Dentes-de-Sabre e Lady Letal ocorre aqui!'),
    ('V1 #4',
     'SEGREDOS DO PROJETO ARMA X — Uma invasão às instalações do Projeto Arma X desperta memórias vívidas e terríveis de Wolverine! Jean Grey e o Professor X ajudam Logan a desbloquear segredos de seu passado para que ele possa reclamar seu presente!')
)
UPDATE itens_ordem_leitura item
SET observacao = left(descricao.texto || E'\n\n' || coalesce(item.observacao, ''), 1000)
FROM descricoes descricao, ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND lower(trim(item.titulo_referencia)) = lower('A Saga do Wolverine')
  AND item.detalhe_referencia = descricao.detalhe;

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
    WHERE lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
      AND item.detalhe_referencia = 'V1 #35'
), prioridades AS (
    SELECT item.id,
        CASE
            WHEN lower(trim(item.titulo_referencia)) = lower('X-Factor Omnibus')
                 AND item.detalhe_referencia = 'V1 #1' THEN 1
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga do Wolverine')
                 AND item.detalhe_referencia = 'V1 #1' THEN 2
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga do Wolverine')
                 AND item.detalhe_referencia = 'V1 #2' THEN 3
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga do Wolverine')
                 AND item.detalhe_referencia = 'V1 #3' THEN 4
            WHEN lower(trim(item.titulo_referencia)) = lower('A Saga do Wolverine')
                 AND item.detalhe_referencia = 'V1 #4' THEN 5
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
        THEN 'Nova formação do X-Factor e Wolverine por Larry Hama e Marc Silvestri'
        ELSE item.secao
    END
FROM ranqueados ranqueado
WHERE item.id = ranqueado.id;
