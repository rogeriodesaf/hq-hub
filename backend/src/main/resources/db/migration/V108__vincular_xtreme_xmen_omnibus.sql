-- Vincula o item da Ordem de Leitura Mutante ao Omnibus já cadastrado com
-- capa no catálogo. "X-Treme X-Men: Um Novo Início" é uma obra distinta.
WITH candidato AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM itens_ordem_leitura item
    JOIN editoras editora
      ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND lower(trim(serie.titulo)) = lower('X-Treme X-Men By Chris Claremont Omnibus')
     AND coalesce(serie.volume, 1) = 1
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') = '1'
    WHERE lower(trim(item.titulo_referencia)) = lower('X-Treme X-Men Omnibus')
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidato.edicao_id
FROM candidato
WHERE item.id = candidato.item_id;
