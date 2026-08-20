-- As posições 45 a 89 já foram revisadas em V183. Esta migração completa o
-- intervalo solicitado até a posição 115 e mantém o mesmo padrão editorial.

UPDATE itens_ordem_leitura item
SET secao = CASE
    WHEN item.posicao BETWEEN 90 AND 95 THEN 'Equipes Azul e Dourada e a chegada de Bishop'
    WHEN item.posicao BETWEEN 96 AND 102 THEN 'Wolverine: memórias, caçadas e acertos de contas'
    WHEN item.posicao BETWEEN 103 AND 109 THEN 'Grandes conflitos mutantes dos anos 1990'
    WHEN item.posicao BETWEEN 110 AND 115 THEN 'Cable, Ciclope e Fênix'
END
FROM ordens_leitura ordem
WHERE item.ordem_leitura_id = ordem.id
  AND ordem.slug = 'ordem-de-leitura-mutante'
  AND item.posicao BETWEEN 90 AND 115;

WITH itens_alvo AS (
    SELECT item.id, item.edicao_id, item.observacao
    FROM itens_ordem_leitura item
    JOIN ordens_leitura ordem ON ordem.id = item.ordem_leitura_id
    WHERE ordem.slug = 'ordem-de-leitura-mutante'
      AND item.posicao BETWEEN 90 AND 115
), totais AS (
    SELECT alvo.id AS item_id, count(DISTINCT conteudo.historia_id) AS total_historias
    FROM itens_alvo alvo
    LEFT JOIN conteudos_edicoes conteudo ON conteudo.edicao_id = alvo.edicao_id
    GROUP BY alvo.id
), correspondencias AS (
    SELECT DISTINCT
        alvo.id AS item_id,
        outro.id AS outro_item_id,
        concat(
            outro.titulo_referencia,
            CASE WHEN outro.detalhe_referencia IS NULL THEN '' ELSE ' — ' || outro.detalhe_referencia END
        ) AS outra_edicao,
        conteudo.historia_id
    FROM itens_alvo alvo
    JOIN conteudos_edicoes conteudo ON conteudo.edicao_id = alvo.edicao_id
    JOIN conteudos_edicoes repeticao
      ON repeticao.historia_id = conteudo.historia_id
     AND repeticao.edicao_id <> conteudo.edicao_id
    JOIN itens_ordem_leitura outro
      ON outro.edicao_id = repeticao.edicao_id
     AND outro.ordem_leitura_id = (SELECT id FROM ordens_leitura WHERE slug = 'ordem-de-leitura-mutante')
     AND outro.id <> alvo.id
), edicoes_repetidas AS (
    SELECT item_id, outro_item_id, outra_edicao, count(DISTINCT historia_id) AS historias_em_comum
    FROM correspondencias
    GROUP BY item_id, outro_item_id, outra_edicao
), resumos AS (
    SELECT
        repeticao.item_id,
        string_agg(
            repeticao.outra_edicao || ' (' || repeticao.historias_em_comum ||
            CASE WHEN repeticao.historias_em_comum = total.total_historias
                 THEN ' histórias; todo o conteúdo identificado)'
                 ELSE ' histórias em comum)'
            END,
            '; ' ORDER BY repeticao.outra_edicao
        ) AS outras_edicoes
    FROM edicoes_repetidas repeticao
    JOIN totais total ON total.item_id = repeticao.item_id
    GROUP BY repeticao.item_id
), notas AS (
    SELECT
        alvo.id AS item_id,
        CASE
            WHEN alvo.edicao_id IS NULL THEN
                E'REPUBLICAÇÕES NO GUIA\nEsta edição ainda não está vinculada ao catálogo; por isso, a comparação de histórias permanece pendente de revisão.'
            WHEN total.total_historias = 0 THEN
                E'REPUBLICAÇÕES NO GUIA\nO conteúdo desta edição ainda não foi detalhado no catálogo; por isso, a comparação permanece pendente de revisão.'
            WHEN resumo.outras_edicoes IS NULL THEN
                E'HISTÓRIAS EXCLUSIVAS NESTE GUIA\nNão foi encontrada outra edição do guia com as mesmas histórias cadastradas.'
            ELSE
                E'HISTÓRIAS TAMBÉM PUBLICADAS EM OUTRAS EDIÇÕES\n' || resumo.outras_edicoes ||
                E'. Você pode escolher entre as edições que contêm as mesmas histórias; não é necessário relê-las.'
        END AS nota
    FROM itens_alvo alvo
    JOIN totais total ON total.item_id = alvo.id
    LEFT JOIN resumos resumo ON resumo.item_id = alvo.id
)
UPDATE itens_ordem_leitura item
SET observacao = CASE
    WHEN coalesce(trim(item.observacao), '') = '' THEN left(nota.nota, 1000)
    WHEN position(nota.nota IN item.observacao) > 0 THEN item.observacao
    ELSE left(item.observacao, greatest(0, 998 - length(nota.nota))) || E'\n\n' || left(nota.nota, 998)
END
FROM notas nota
WHERE item.id = nota.item_id;
