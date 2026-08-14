-- Vincula as 35 entradas de Wolverine V2 e V3 da Ordem de Leitura Mutante
-- às respectivas séries brasileiras da Panini.

WITH referencias(volume, numero) AS (
    SELECT 2, generate_series(1, 14)
    UNION ALL
    SELECT 3, generate_series(1, 21)
), candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM referencias referencia
    JOIN itens_ordem_leitura item
      ON lower(trim(item.titulo_referencia)) = lower('Wolverine')
     AND substring(item.detalhe_referencia FROM 'V([0-9]+)')::integer = referencia.volume
     AND substring(item.detalhe_referencia FROM '#([0-9]+)')::integer = referencia.numero
    JOIN editoras editora
      ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND lower(trim(serie.titulo)) = lower('Wolverine')
     AND serie.volume = referencia.volume
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND substring(edicao.numero FROM '([0-9]+)')::integer = referencia.numero
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;
