-- Reúne A Canção do Carrasco e Atrações Fatais em uma etapa própria.

WITH descricoes(detalhe, texto) AS (VALUES
    ('V2 #7',
     'A CANÇÃO DO CARRASCO — O vilão Conflyto, clone de Cable, comete um atentado contra Xavier durante um discurso. Por acreditarem que Cable é o responsável, todas as equipes mutantes passam a enfrentar a X-Force.'),
    ('V2 #9',
     'A CANÇÃO DO CARRASCO — CONCLUSÃO — Fim do arco A Canção do Carrasco.')
)
UPDATE itens_ordem_leitura item
SET observacao = left(descricao.texto || E'\n\n' || coalesce(item.observacao, ''), 1000)
FROM descricoes descricao, ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
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
    WHERE lower(trim(item.titulo_referencia)) = lower('A Saga do Wolverine')
      AND item.detalhe_referencia = 'V1 #8'
), prioridades AS (
    SELECT item.id,
           CASE item.detalhe_referencia
               WHEN 'V2 #7' THEN 1
               WHEN 'V2 #8' THEN 2
               WHEN 'V2 #9' THEN 3
               WHEN 'V2 #10' THEN 4
               WHEN 'V2 #11' THEN 5
               WHEN 'V2 #12' THEN 6
               WHEN 'V2 #13' THEN 7
           END AS ordem_etapa
    FROM itens_ordem_leitura item JOIN ordem ON ordem.id = item.ordem_leitura_id
    WHERE lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
      AND item.detalhe_referencia IN ('V2 #7', 'V2 #8', 'V2 #9', 'V2 #10', 'V2 #11', 'V2 #12', 'V2 #13')
), ranqueados AS (
    SELECT item.id,
           row_number() OVER (
               ORDER BY CASE
                   WHEN prioridade.ordem_etapa IS NOT NULL
                       THEN marco.posicao_original + prioridade.ordem_etapa / 100.0
                   ELSE item.posicao - 100000
               END,
               item.id
           ) AS nova_posicao,
           prioridade.ordem_etapa
    FROM itens_ordem_leitura item
    JOIN ordem ON ordem.id = item.ordem_leitura_id
    LEFT JOIN prioridades prioridade ON prioridade.id = item.id
    CROSS JOIN marco
)
UPDATE itens_ordem_leitura item
SET posicao = ranqueado.nova_posicao,
    secao = CASE WHEN ranqueado.ordem_etapa IS NOT NULL
        THEN 'A Canção do Carrasco e Atrações Fatais'
        ELSE item.secao
    END
FROM ranqueados ranqueado
WHERE item.id = ranqueado.id;
