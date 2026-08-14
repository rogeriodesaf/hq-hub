-- Vincula os volumes da coleção Panini de 2012 aos itens correspondentes
-- da Ordem de Leitura Mutante. As capas já existem no catálogo e passam a
-- ser retornadas pela API assim que os itens recebem o edicao_id correto.
WITH candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM itens_ordem_leitura item
    JOIN editoras editora
      ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND lower(trim(serie.titulo)) = lower('X-Men: A Era do Apocalipse')
     AND coalesce(serie.volume, 1) = 1
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') =
         ltrim(substring(item.detalhe_referencia FROM '#([0-9]+)'), '0')
    WHERE lower(trim(item.titulo_referencia)) = lower('X-Men: A Era do Apocalipse')
      AND substring(item.detalhe_referencia FROM '#([0-9]+)') IN ('1', '2')
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;
