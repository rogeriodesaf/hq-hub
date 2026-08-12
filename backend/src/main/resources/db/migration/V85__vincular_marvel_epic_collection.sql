-- Vincula os volumes usados na ordem mutante ao cadastro explícito da Panini V1.
WITH candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM itens_ordem_leitura item
    JOIN series serie
      ON lower(trim(serie.titulo)) = lower('Marvel Epic Collection')
     AND coalesce(serie.volume, 1) = 1
    JOIN editoras editora
      ON editora.id = serie.editora_id
     AND lower(trim(editora.nome)) = lower('Panini')
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND ltrim(edicao.numero, '0') = substring(item.detalhe_referencia FROM '#([0-9]+)')
    WHERE item.edicao_id IS NULL
      AND lower(trim(item.titulo_referencia)) = lower('Marvel Epic Collection')
      AND item.detalhe_referencia IN ('V1 #3', 'V1 #13')
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;
