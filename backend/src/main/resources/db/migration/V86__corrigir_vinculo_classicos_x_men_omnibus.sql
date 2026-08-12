-- O número interno do omnibus pode estar cadastrado como "Único" em vez de 1.
-- Vincula somente quando a série Panini V1 possui uma única edição com capa.
WITH candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM itens_ordem_leitura item
    JOIN series serie
      ON lower(trim(serie.titulo)) = lower('Clássicos X-Men (Omnibus)')
     AND coalesce(serie.volume, 1) = 1
    JOIN editoras editora
      ON editora.id = serie.editora_id
     AND lower(trim(editora.nome)) = lower('Panini')
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND edicao.url_capa IS NOT NULL
     AND trim(edicao.url_capa) <> ''
    WHERE lower(trim(item.titulo_referencia)) = lower('Clássicos X-Men Omnibus')
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;
