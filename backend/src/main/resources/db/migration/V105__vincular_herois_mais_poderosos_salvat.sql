-- Normaliza as referências da coleção Salvat na Ordem de Leitura Mutante.
-- O volume 15 estava ligado a uma série duplicada atribuída à Panini e o
-- volume 35 ainda não possuía vínculo com o catálogo.
WITH referencias(numero) AS (VALUES ('15'), ('35')),
candidatos AS (
    SELECT item.id AS item_id, min(edicao.id) AS edicao_id
    FROM referencias referencia
    JOIN itens_ordem_leitura item
      ON lower(trim(item.titulo_referencia)) = lower('Os Heróis Mais Poderosos da Marvel')
     AND substring(item.detalhe_referencia FROM '#([0-9]+)') = referencia.numero
    JOIN editoras editora
      ON lower(trim(editora.nome)) = lower('Salvat')
    JOIN series serie
      ON serie.editora_id = editora.id
     AND lower(trim(serie.titulo)) = lower('Os Heróis Mais Poderosos da Marvel')
     AND coalesce(serie.volume, 1) = 1
    JOIN edicoes edicao
      ON edicao.serie_id = serie.id
     AND ltrim(substring(edicao.numero FROM '([0-9]+)'), '0') = referencia.numero
    GROUP BY item.id
    HAVING count(*) = 1
)
UPDATE itens_ordem_leitura item
SET edicao_id = candidatos.edicao_id
FROM candidatos
WHERE item.id = candidatos.item_id;
