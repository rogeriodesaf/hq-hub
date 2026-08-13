-- Vincula os encadernados existentes no catalogo aos itens da ordem mutante.
WITH referencias(titulo_ordem, titulo_catalogo) AS (VALUES
    ('As Maiores Sagas dos X-Men: Aliança Falange', 'X-Men: Aliança Falange'),
    ('X-Men: A Era do Apocalipse Omnibus', 'X-Men: A Era do Apocalipse Omnibus')
), candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM referencias referencia
    JOIN itens_ordem_leitura item
      ON lower(trim(item.titulo_referencia)) = lower(referencia.titulo_ordem)
    JOIN editoras editora
      ON lower(trim(editora.nome)) = lower('Panini')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND lower(trim(serie.titulo)) = lower(referencia.titulo_catalogo)
     AND coalesce(serie.volume, 1) = 1
    JOIN edicoes edicao ON edicao.serie_id = serie.id
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;

UPDATE itens_ordem_leitura
SET titulo_referencia = 'X-Men: Aliança Falange'
WHERE lower(trim(titulo_referencia)) =
      lower('As Maiores Sagas dos X-Men: Aliança Falange');
