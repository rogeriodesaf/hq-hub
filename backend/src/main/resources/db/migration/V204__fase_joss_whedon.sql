-- Cria uma etapa própria para a fase de Joss Whedon em Surpreendentes X-Men.

WITH descricoes(titulo, detalhe, texto) AS (VALUES
    ('Surpreendentes X-Men: Edição Especial', NULL,
     'FASE JOSS WHEDON — Kitty Pryde e Colossus retornam à equipe e, junto com eles, surgem novos perigos. Uma ótima fase compilada neste encadernado.'),
    ('Surpreendentes X-Men', 'V1 #2',
     'FASE JOSS WHEDON — CONCLUSÃO — Final da incrível fase de Joss Whedon.')
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
    WHERE lower(trim(item.titulo_referencia)) = lower('Novos X-Men Por Grant Morrison')
      AND item.detalhe_referencia = 'V1 #7'
), prioridades AS (
    SELECT item.id,
        CASE
            WHEN lower(trim(item.titulo_referencia)) = lower('Surpreendentes X-Men: Edição Especial') THEN 1
            WHEN lower(trim(item.titulo_referencia)) = lower('Surpreendentes X-Men') AND item.detalhe_referencia = 'V1 #2' THEN 2
            WHEN lower(trim(item.titulo_referencia)) = lower('Surpreendentes X-Men') AND item.detalhe_referencia = 'V1 #3' THEN 3
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
        THEN 'Fase Joss Whedon'
        ELSE item.secao
    END
FROM ranqueados ranqueado
WHERE item.id = ranqueado.id;
