-- Vincula os nove itens de Guerras Secretas V2 da ordem mutante às edições
-- brasileiras do catálogo para que suas capas sejam exibidas.

WITH referencias(numero) AS (
    SELECT generate_series(1, 9)
), candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM referencias referencia
    JOIN itens_ordem_leitura item
      ON lower(trim(item.titulo_referencia)) = lower('Guerras Secretas')
     AND lower(trim(item.detalhe_referencia)) = lower('V2 #' || referencia.numero)
    JOIN editoras editora
      ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND lower(trim(serie.titulo)) = lower('Guerras Secretas')
     AND coalesce(serie.volume, 0) = 2
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND substring(edicao.numero FROM '([0-9]+)')::integer = referencia.numero
     AND edicao.url_capa IS NOT NULL
     AND trim(edicao.url_capa) <> ''
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;
