-- O catálogo usa o artigo no fim ("Saga dos X-Men, A"), enquanto a ordem de
-- leitura usa a forma natural ("A Saga dos X-Men"). O volume evita cruzar V1 e V2.
WITH candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM itens_ordem_leitura item
    JOIN series serie
      ON lower(trim(serie.titulo)) = lower('Saga dos X-Men, A')
     AND serie.volume = substring(item.detalhe_referencia FROM '^V([0-9]+)')::INTEGER
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND edicao.numero = substring(item.detalhe_referencia FROM '#([0-9]+)')
    WHERE item.edicao_id IS NULL
      AND lower(trim(item.titulo_referencia)) = lower('A Saga dos X-Men')
      AND item.detalhe_referencia ~ '^V[0-9]+ #[0-9]+'
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;
