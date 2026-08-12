-- Vincula somente correspondencias unicas de titulo, volume e numero. Itens
-- ambiguos permanecem como referencia, evitando associar uma capa errada.
WITH candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM itens_ordem_leitura item
    JOIN series serie
      ON lower(trim(serie.titulo)) = lower(trim(item.titulo_referencia))
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND edicao.numero = substring(item.detalhe_referencia FROM '#([0-9]+)')
    WHERE item.edicao_id IS NULL
      AND item.detalhe_referencia ~ '#[0-9]+'
      AND (
          item.detalhe_referencia !~ '^V[0-9]+'
          OR serie.volume = substring(item.detalhe_referencia FROM '^V([0-9]+)')::INTEGER
      )
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;
